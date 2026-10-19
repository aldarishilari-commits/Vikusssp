import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';
import 'geoapify_service.dart';

/// Modelo para una sugerencia de búsqueda de lugares
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structured?['main_text'] as String? ??
          json['description'] as String? ??
          '',
      secondaryText: structured?['secondary_text'] as String? ?? '',
    );
  }
}

/// Modelo para el detalle de ubicación obtenido de un lugar
class PlaceLocationResult {
  final String address;
  final double latitude;
  final double longitude;

  const PlaceLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Servicio híbrido para interactuar con Google Places, Geoapify y OSM Nominatim
class GooglePlacesService {
  final http.Client _client;
  final GeoapifyService _geoapifyService;

  GooglePlacesService({http.Client? client})
      : _client = client ?? http.Client(),
        _geoapifyService = GeoapifyService(client: client);

  List<String> get _candidateKeys => [
        GoogleMapsConfig.mapsJsApiKey,
        GoogleMapsConfig.apiKey,
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

    // 1. Primario: Google Places Autocomplete API
    for (final key in _candidateKeys) {
      final queryParams = <String, String>{
        'input': cleanQuery,
        'key': key,
        'language': 'es',
        'components': 'country:bo', // Prioridad en Bolivia
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
          } else if (status == 'ZERO_RESULTS') {
            // Intento sin restricción de país si no hubo resultados locales
            final globalUrl = Uri.parse(
              'https://maps.googleapis.com/maps/api/place/autocomplete/json'
              '?input=${Uri.encodeComponent(cleanQuery)}'
              '&key=$key'
              '&language=es',
            );
            final globalRes = await _client.get(globalUrl);
            if (globalRes.statusCode == 200) {
              final globalData =
                  jsonDecode(globalRes.body) as Map<String, dynamic>;
              if (globalData['status'] == 'OK') {
                final globalPreds =
                    globalData['predictions'] as List<dynamic>? ?? [];
                if (globalPreds.isNotEmpty) {
                  return globalPreds
                      .map((p) =>
                          PlacePrediction.fromJson(p as Map<String, dynamic>))
                      .toList();
                }
              }
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

  /// Obtiene las coordenadas y dirección formateada a partir de un placeId
  Future<PlaceLocationResult?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    // 1. Si no es un ID con prefijo de Geoapify u OSM, es de Google Places:
    if (!placeId.startsWith('geoapify_') && !placeId.startsWith('osm_')) {
      for (final key in _candidateKeys) {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address,name'
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
                final formattedAddress =
                    result?['formatted_address'] as String? ??
                        result?['name'] as String? ??
                        '';

                return PlaceLocationResult(
                  address: formattedAddress,
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

  /// Convierte coordenadas geográficas en una dirección legible (Reverse Geocoding)
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    // 1. Geoapify Reverse Geocoding (para direcciones con numeración y barrio)
    final geoapifyResult =
        await _geoapifyService.reverseGeocode(latitude, longitude);
    if (geoapifyResult != null && geoapifyResult.isNotEmpty) {
      return geoapifyResult;
    }

    // 2. Google Maps Geocoding API
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
              final first = results.first as Map<String, dynamic>;
              final formatted = first['formatted_address'] as String?;
              if (formatted != null && formatted.isNotEmpty) {
                return formatted;
              }
            }
          }
        }
      } catch (_) {}
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
