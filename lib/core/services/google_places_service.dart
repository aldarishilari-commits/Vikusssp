import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';
import 'geoapify_service.dart';

export 'geoapify_service.dart'
    show
        PlacePrediction,
        PlaceLocationResult,
        GeoapifyPlaceItem,
        GeoapifyService,
        GeoapifyReverseResult;


/// Servicio híbrido para interactuar con Google Places, Geoapify y OSM Nominatim
class GooglePlacesService {
  final http.Client _client;
  final GeoapifyService _geoapifyService;

  GooglePlacesService({http.Client? client})
      : _client = client ?? http.Client(),
        _geoapifyService = GeoapifyService(client: client);

  List<String> get _candidateKeys => [
        GoogleMapsConfig.apiKey,
        GoogleMapsConfig.mapsJsApiKey,
      ];

  /// Obtiene predicciones de autocompletado para una consulta de texto.
  /// Utiliza Google Places Autocomplete API como motor principal.
  Future<List<PlacePrediction>> getAutocompletePredictions(
    String query, {
    double? biasLat,
    double? biasLng,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // 1. Primario: Google Places Autocomplete API (con sesgo geográfico por cercanía)
    for (final key in _candidateKeys) {
      final queryParams = <String, String>{
        'input': cleanQuery,
        'key': key,
        'language': 'es',
      };

      if (biasLat != null && biasLng != null) {
        queryParams['location'] = '$biasLat,$biasLng';
        queryParams['radius'] = '50000'; // 50 km de radio de búsqueda
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      ).replace(queryParameters: queryParams);

      try {
        final response = await _client.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String?;

          if (status == 'OK') {
            final predictions = data['predictions'] as List<dynamic>? ?? [];
            if (predictions.isNotEmpty) {
              return predictions
                  .map((p) =>
                      PlacePrediction.fromJson(p as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fallback: Geoapify Autocomplete
    final geoapifyResults = await _geoapifyService.getAutocompletePredictions(
      cleanQuery,
      biasLat: biasLat,
      biasLng: biasLng,
    );
    if (geoapifyResults.isNotEmpty) {
      return geoapifyResults;
    }

    // 3. Fallback: OpenStreetMap Nominatim
    return _searchNominatim(cleanQuery);
  }

  /// Búsqueda con OpenStreetMap Nominatim
  Future<List<PlacePrediction>> _searchNominatim(String query) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json'
        '&q=${Uri.encodeComponent(query)}'
        '&countrycodes=bo'
        '&limit=6'
        '&addressdetails=1',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'AeronpulseApp/1.0 (osm@aeronpulse.app)',
          'Accept-Language': 'es',
        },
      );

      if (response.statusCode == 200) {
        final list =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return list.map((item) {
          final map = item as Map<String, dynamic>;
          final displayName = map['display_name'] as String? ?? '';
          final parts = displayName.split(',');
          final main = parts.isNotEmpty ? parts.first.trim() : displayName;
          final secondary =
              parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

          final lat = map['lat']?.toString() ?? '0';
          final lon = map['lon']?.toString() ?? '0';

          return PlacePrediction(
            placeId: 'osm_${map['place_id']}_${lat}_$lon',
            description: displayName,
            mainText: main,
            secondaryText: secondary,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Limpia códigos Plus Code y sufijos redundantes
  static String cleanAddress(String raw) {
    var clean = raw.trim();
    // Remueve Plus Codes al inicio como "FW56+HM7, " o "FVPC+XV "
    clean = clean.replaceAll(
      RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,4}(,\s*|\s+)?', caseSensitive: false),
      '',
    );
    clean = clean.replaceAll(
      RegExp(r'^[A-Z0-9]{2,4}\+[A-Z0-9]{2,4}(,\s*|\s+)?', caseSensitive: false),
      '',
    );
    // Remueve ", Bolivia" al final para formato conciso y local
    clean = clean.replaceAll(RegExp(r',\s*Bolivia$', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r',\s*Argentina$', caseSensitive: false), '');
    return clean.trim();
  }

  /// Formatea la dirección en su versión corta y concisa para el perfil
  /// (ej: "Piedras 57", "Av. Belgrano 300", "Av. Corrientes 59", "Av. 16 de Julio 1525")
  static String toShortAddress(String raw) {
    final cleaned = cleanAddress(raw);
    if (cleaned.isEmpty) return raw.trim();
    final firstPart = cleaned.split(',').first.trim();
    return firstPart.isNotEmpty ? firstPart : cleaned;
  }

  /// Formatea la dirección obtenida en los detalles de un lugar de Google
  static String formatPlaceDetailsAddress(
      Map<String, dynamic>? result, String fallback) {
    if (result == null) return cleanAddress(fallback);

    final raw = result['formatted_address'] as String? ?? fallback;
    final cleaned = cleanAddress(raw);

    final comps = (result['address_components'] as List?) ?? [];
    String? neighborhood;
    String? sublocality;
    String? city;

    for (final comp in comps) {
      final types = (comp['types'] as List).cast<String>();
      final name = comp['long_name'] as String? ?? '';
      if (name.isEmpty) continue;
      if (types.contains('neighborhood')) {
        neighborhood = name;
      } else if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        sublocality ??= name.replaceAll('Macrodistrito ', '');
      }
      if (types.contains('locality')) {
        city = name;
      }
    }

    final zone = neighborhood ?? sublocality;
    if (cleaned.isNotEmpty && zone != null && zone.isNotEmpty) {
      if (!cleaned.toLowerCase().contains(zone.toLowerCase())) {
        if (city != null && cleaned.contains(city)) {
          return cleaned.replaceFirst(city, '$zone, $city');
        }
        return '$cleaned, $zone';
      }
    }

    return cleaned.isNotEmpty ? cleaned : cleanAddress(fallback);
  }

  /// Extrae la dirección más exacta, legible y sin nombres de locales ajenos
  /// de los resultados de Google Geocoding API.
  static String? extractExactAddressFromGoogle(List<dynamic> results) {
    if (results.isEmpty) return null;

    String? detectedNeighborhood;
    String? detectedSublocality;
    String? detectedCity;

    // 1. Recorrer todos los resultados para capturar el barrio/zona y ciudad
    for (final r in results) {
      final comps = (r['address_components'] as List?) ?? [];
      for (final comp in comps) {
        final cTypes = (comp['types'] as List).cast<String>();
        final name = comp['long_name'] as String? ?? '';
        if (name.isEmpty) continue;
        if (detectedNeighborhood == null && cTypes.contains('neighborhood')) {
          detectedNeighborhood = name;
        }
        if (detectedSublocality == null &&
            (cTypes.contains('sublocality') ||
                cTypes.contains('sublocality_level_1'))) {
          detectedSublocality = name.replaceAll('Macrodistrito ', '');
        }
        if (detectedCity == null && cTypes.contains('locality')) {
          detectedCity = name;
        }
      }
    }

    final zone = detectedNeighborhood ?? detectedSublocality;

    // 2. Puntuar candidatos para priorizar calles con numeración y descartar locales de terceros
    Map<String, dynamic>? bestResult;
    int bestScore = -99999;

    const commercialTypes = [
      'beauty_salon',
      'store',
      'hair_care',
      'dentist',
      'doctor',
      'restaurant',
      'cafe',
      'bar',
      'bank',
      'atm',
      'lodging',
      'insurance_agency',
      'health',
      'shopping_mall',
    ];

    for (final r in results) {
      final types = (r['types'] as List).cast<String>();
      final formatted = r['formatted_address'] as String? ?? '';
      int score = 0;

      // Descartar o penalizar severamente Plus Codes
      if (types.contains('plus_code') ||
          RegExp(r'^[A-Z0-9]{4,8}\+').hasMatch(formatted)) {
        score -= 500;
      }

      // Máxima prioridad a direcciones exactas con número o subpremisa
      if (types.contains('street_address') || types.contains('subpremise')) {
        score += 300;
      } else if (types.contains('premise')) {
        score += 200;
      } else if (types.contains('route')) {
        score += 150;
      } else if (types.contains('intersection')) {
        score += 120;
      } else if (types.contains('neighborhood') ||
          types.contains('sublocality')) {
        score += 80;
      }

      // Penalizar comercios de terceros para evitar que ponga el nombre de otra tienda
      if (types.any((t) => commercialTypes.contains(t))) {
        score -= 90;
      }

      // Penalizar nombres truncados como "Calle 15 y,"
      if (RegExp(r'\s+y,', caseSensitive: false).hasMatch(formatted)) {
        score -= 100;
      }

      // Penalizar resultados demasiado generales (país, provincia o departamento)
      if (types.contains('country') ||
          types.contains('administrative_area_level_1') ||
          types.contains('administrative_area_level_2')) {
        score -= 200;
      }

      if (score > bestScore) {
        bestScore = score;
        bestResult = r as Map<String, dynamic>;
      }
    }

    if (bestResult == null) return null;

    // 3. Extraer componentes del mejor candidato
    final comps = (bestResult['address_components'] as List?) ?? [];
    String? streetNumber;
    String? route;
    String? localNeighborhood = zone;
    String? localCity = detectedCity;

    for (final comp in comps) {
      final cTypes = (comp['types'] as List).cast<String>();
      final name = comp['long_name'] as String? ?? '';
      if (name.isEmpty) continue;
      if (cTypes.contains('street_number')) streetNumber = name;
      if (cTypes.contains('route')) route = name;
      if (cTypes.contains('neighborhood')) localNeighborhood = name;
      if (cTypes.contains('locality')) localCity = name;
    }

    // 4. Si tenemos calle y no es genérica ("Sin nombre"), armar formato profesional
    if (route != null &&
        route.isNotEmpty &&
        !route.toLowerCase().contains('sin nombre')) {
      final parts = <String>[];
      final streetPart = (streetNumber != null &&
              streetNumber.isNotEmpty &&
              streetNumber.toLowerCase() != 'y')
          ? '$route $streetNumber'
          : route;
      parts.add(streetPart);

      if (localNeighborhood != null &&
          localNeighborhood.isNotEmpty &&
          !parts.contains(localNeighborhood)) {
        parts.add(localNeighborhood);
      }
      if (localCity != null &&
          localCity.isNotEmpty &&
          !parts.contains(localCity)) {
        parts.add(localCity);
      }
      return parts.join(', ');
    }

    // 5. Fallback con limpieza de formatted_address
    final rawFormatted = bestResult['formatted_address'] as String? ?? '';
    final cleaned = cleanAddress(rawFormatted);
    if (cleaned.isNotEmpty) {
      if (localNeighborhood != null &&
          localNeighborhood.isNotEmpty &&
          !cleaned.toLowerCase().contains(localNeighborhood.toLowerCase())) {
        if (localCity != null && cleaned.contains(localCity)) {
          return cleaned.replaceFirst(
              localCity, '$localNeighborhood, $localCity');
        }
        return '$cleaned, $localNeighborhood';
      }
      return cleaned;
    }

    return null;
  }

  /// Obtiene las coordenadas y dirección formateada a partir de un placeId
  Future<PlaceLocationResult?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    // 1. Si no es un ID con prefijo de Geoapify u OSM, es de Google Places:
    if (!placeId.startsWith('geoapify_') && !placeId.startsWith('osm_')) {
      for (final key in _candidateKeys) {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address,name,address_components'
          '&key=$key'
          '&language=es',
        );

        try {
          final response = await _client.get(url);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            if (data['status'] == 'OK') {
              final result = data['result'] as Map<String, dynamic>?;
              final geometry = result?['geometry'] as Map<String, dynamic>?;
              final location = geometry?['location'] as Map<String, dynamic>?;

              if (location != null) {
                final lat = (location['lat'] as num).toDouble();
                final lng = (location['lng'] as num).toDouble();
                final rawAddress = result?['formatted_address'] as String? ??
                    result?['name'] as String? ??
                    '';
                final formattedAddress =
                    formatPlaceDetailsAddress(result, rawAddress);
                final shortAddress = toShortAddress(
                    rawAddress.isNotEmpty ? rawAddress : formattedAddress);

                return PlaceLocationResult(
                  address: formattedAddress,
                  shortAddress: shortAddress,
                  latitude: lat,
                  longitude: lng,
                );
              }
            }
          }
        } catch (_) {}
      }
    }

    // 2. Si es un ID de Geoapify:
    if (placeId.startsWith('geoapify_')) {
      return _geoapifyService.getPlaceDetails(placeId);
    }

    // 3. Si es un ID de OpenStreetMap Nominatim:
    if (placeId.startsWith('osm_')) {
      final parts = placeId.split('_');
      if (parts.length >= 4) {
        final lat = double.tryParse(parts[2]);
        final lng = double.tryParse(parts[3]);
        if (lat != null && lng != null) {
          final address = await reverseGeocode(lat, lng) ?? '';
          return PlaceLocationResult(
            address: address,
            latitude: lat,
            longitude: lng,
          );
        }
      }
    }

    return null;
  }

  /// Convierte coordenadas geográficas en una dirección exacta y legible (Reverse Geocoding)
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    // 1. Google Maps Geocoding API (Prioridad principal con ranking de exactitud)
    for (final key in _candidateKeys) {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=$key'
        '&language=es',
      );

      try {
        final response = await _client.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final results = data['results'] as List<dynamic>?;
            if (results != null && results.isNotEmpty) {
              final exact = extractExactAddressFromGoogle(results);
              if (exact != null && exact.isNotEmpty) {
                return exact;
              }
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fallback: Geoapify Reverse Geocoding
    final geoapifyResult =
        await _geoapifyService.reverseGeocode(latitude, longitude);
    if (geoapifyResult != null && geoapifyResult.isNotEmpty) {
      return geoapifyResult;
    }

    // 3. Fallback con OpenStreetMap Nominatim
    return _reverseGeocodeNominatim(latitude, longitude);
  }

  /// Geocodificación inversa de respaldo con OpenStreetMap Nominatim
  Future<String?> _reverseGeocodeNominatim(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=18'
        '&addressdetails=1',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'AeronpulseApp/1.0 (osm@aeronpulse.app)',
          'Accept-Language': 'es',
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final road = address['road'] ??
              address['pedestrian'] ??
              address['suburb'] ??
              address['neighbourhood'];
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['state'];
          if (road != null && city != null) {
            return '$road, $city';
          }
        }
        return data['display_name'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
