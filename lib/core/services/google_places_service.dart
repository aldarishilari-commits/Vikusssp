import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/google_maps_config.dart';

/// Modelo para una sugerencia de búsqueda de Google Places
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
      mainText: structured?['main_text'] as String? ?? json['description'] as String? ?? '',
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

/// Servicio para interactuar con Google Places Autocomplete, Details y Geocoding API
class GooglePlacesService {
  final http.Client _client;

  GooglePlacesService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene predicciones de autocompletado para una consulta de texto
  Future<List<PlacePrediction>> getAutocompletePredictions(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(query)}'
      '&key=${GoogleMapsConfig.apiKey}'
      '&language=es',
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK' || status == 'ZERO_RESULTS') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          // Log or handle error status (e.g. REQUEST_DENIED, OVER_QUERY_LIMIT)
          return [];
        }
      }
    } catch (_) {
      // Fallback on network failure
    }
    return [];
  }

  /// Obtiene las coordenadas y dirección formateada a partir de un placeId
  Future<PlaceLocationResult?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry,formatted_address,name'
      '&key=${GoogleMapsConfig.apiKey}'
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
            final formattedAddress = result?['formatted_address'] as String? ??
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
    return null;
  }

  /// Convierte coordenadas geográficas en una dirección legible (Reverse Geocoding)
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$latitude,$longitude'
      '&key=${GoogleMapsConfig.apiKey}'
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
            return first['formatted_address'] as String?;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
