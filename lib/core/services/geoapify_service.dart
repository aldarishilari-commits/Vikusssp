import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/geoapify_config.dart';
import 'google_places_service.dart';

/// Modelo con los datos detallados de geocodificación inversa de Geoapify
class GeoapifyReverseResult {
  final String formatted;
  final String cleanAddress;
  final String? street;
  final String? houseNumber;
  final String? suburb;
  final String? city;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> rawProperties;

  const GeoapifyReverseResult({
    required this.formatted,
    required this.cleanAddress,
    this.street,
    this.houseNumber,
    this.suburb,
    this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
    required this.rawProperties,
  });

  factory GeoapifyReverseResult.fromProperties(
    Map<String, dynamic> props,
    double defaultLat,
    double defaultLng,
  ) {
    final street = props['street'] as String?;
    final houseNumber = props['housenumber'] as String?;
    final suburb =
        props['suburb'] as String? ?? props['neighbourhood'] as String?;
    final city = props['city'] as String? ?? props['state'] as String?;
    final state = props['state'] as String?;
    final country = props['country'] as String?;
    final formatted = props['formatted'] as String? ?? '';
    final lat = (props['lat'] as num?)?.toDouble() ?? defaultLat;
    final lon = (props['lon'] as num?)?.toDouble() ?? defaultLng;

    final cleanAddress =
        GeoapifyService.formatAddress(props, includeVenueName: false);

    return GeoapifyReverseResult(
      formatted: formatted,
      cleanAddress: cleanAddress.isNotEmpty ? cleanAddress : formatted,
      street: street,
      houseNumber: houseNumber,
      suburb: suburb,
      city: city,
      state: state,
      country: country,
      latitude: lat,
      longitude: lon,
      rawProperties: props,
    );
  }
}

/// Servicio para interactuar con Geoapify Geocoding API (Reverse Geocoding y Autocomplete)
class GeoapifyService {
  final http.Client _client;
  final String _apiKey;

  GeoapifyService({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? GeoapifyConfig.apiKey;

  static String formatAddress(
    Map<String, dynamic> props, {
    bool includeVenueName = true,
  }) {
    final street = props['street'] as String?;
    final houseNumber = props['housenumber'] as String?;
    final suburb =
        props['suburb'] as String? ?? props['neighbourhood'] as String?;
    final city = props['city'] as String? ?? props['state'] as String?;
    final name = props['name'] as String?;
    final formatted = props['formatted'] as String? ?? '';

    // 1. Si tenemos calle identificada
    if (street != null && street.isNotEmpty) {
      final streetWithNumber =
          houseNumber != null && houseNumber.isNotEmpty
              ? '$street $houseNumber'
              : street;

      final parts = <String>[];
      if (includeVenueName &&
          name != null &&
          name.isNotEmpty &&
          name != street &&
          name != houseNumber) {
        parts.add(name);
      }
      parts.add(streetWithNumber);

      if (suburb != null && suburb.isNotEmpty && !parts.contains(suburb)) {
        parts.add(suburb);
      } else if (city != null && city.isNotEmpty) {
        final cleanCity = city
            .replaceAll('Municipio Nuestra Señora de ', '')
            .replaceAll('Municipio ', '');
        parts.add(cleanCity);
      }

      return parts.join(', ');
    }

    // 2. Si no hay calle pero hay address_line1
    final line1 = props['address_line1'] as String?;
    if (line1 != null && line1.isNotEmpty) {
      if (suburb != null && suburb.isNotEmpty && !line1.contains(suburb)) {
        return '$line1, $suburb';
      }
      if (city != null && city.isNotEmpty) {
        final cleanCity = city
            .replaceAll('Municipio Nuestra Señora de ', '')
            .replaceAll('Municipio ', '');
        return '$line1, $cleanCity';
      }
      return line1;
    }

    // 3. Fallback al formateado oficial sin ", Bolivia" al final
    if (formatted.isNotEmpty) {
      return formatted.replaceAll(RegExp(r',\s*Bolivia$'), '');
    }

    return '';
  }

  /// Geocodificación Inversa de Geoapify
  /// Convierte coordenadas (latitud, longitud) en el nombre de la dirección
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final detail = await reverseGeocodeDetail(latitude, longitude);
    return detail?.cleanAddress ?? detail?.formatted;
  }

  /// Geocodificación Inversa detallada de Geoapify
  Future<GeoapifyReverseResult?> reverseGeocodeDetail(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '${GeoapifyConfig.baseUrl}/geocode/reverse'
        '?lat=$latitude'
        '&lon=$longitude'
        '&apiKey=$_apiKey'
        '&lang=es',
      );

      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final properties = first['properties'] as Map<String, dynamic>?;
          if (properties != null) {
            return GeoapifyReverseResult.fromProperties(
              properties,
              latitude,
              longitude,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sugerencias de búsqueda con Geoapify Autocomplete
  /// Soporta búsqueda abierta y priorización (bias) por cercanía geográfica
  Future<List<PlacePrediction>> getAutocompletePredictions(
    String query, {
    double? biasLat,
    double? biasLng,
    String? countryCode,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    try {
      final queryParams = <String, String>{
        'text': clean,
        'apiKey': _apiKey,
        'lang': 'es',
        'limit': '7',
      };

      if (biasLat != null && biasLng != null) {
        queryParams['bias'] = 'proximity:$biasLng,$biasLat';
      } else if (countryCode != null && countryCode.isNotEmpty) {
        queryParams['bias'] = 'countrycode:$countryCode';
      } else {
        queryParams['bias'] = 'countrycode:bo';
      }

      final uri = Uri.parse('${GeoapifyConfig.baseUrl}/geocode/autocomplete')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        return features.map((f) {
          final map = f as Map<String, dynamic>;
          final props = map['properties'] as Map<String, dynamic>? ?? {};

          final placeId = props['place_id'] as String? ?? '';
          final formatted = props['formatted'] as String? ?? '';
          final lat = props['lat']?.toString() ?? '0';
          final lon = props['lon']?.toString() ?? '0';

          final line1 = props['address_line1'] as String? ??
              props['name'] as String? ??
              props['street'] as String? ??
              formatted;
          final line2 = props['address_line2'] as String? ??
              props['city'] as String? ??
              props['suburb'] as String? ??
              props['country'] as String? ??
              '';

          return PlacePrediction(
            placeId: 'geoapify_${placeId}_${lat}_$lon',
            description: formatted,
            mainText: line1,
            secondaryText: line2,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Obtiene coordenadas y dirección a partir de una predicción de Geoapify
  Future<PlaceLocationResult?> getPlaceDetails(String placeId) async {
    if (!placeId.startsWith('geoapify_')) return null;

    final parts = placeId.split('_');
    if (parts.length >= 4) {
      final lat = double.tryParse(parts[2]);
      final lng = double.tryParse(parts[3]);
      if (lat != null && lng != null) {
        final address = await reverseGeocode(lat, lng);
        return PlaceLocationResult(
          address: address ?? '',
          latitude: lat,
          longitude: lng,
        );
      }
    }
    return null;
  }
}
