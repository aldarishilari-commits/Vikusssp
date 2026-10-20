import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/geoapify_config.dart';

/// Modelo para una sugerencia de búsqueda de lugares (compatible con autocompletado)
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
  final String shortAddress;
  final double latitude;
  final double longitude;

  const PlaceLocationResult({
    required this.address,
    String? shortAddress,
    required this.latitude,
    required this.longitude,
  }) : shortAddress = shortAddress ?? address;
}

/// Modelo con los datos de un lugar / POI retornado por Geoapify Places API v2
class GeoapifyPlaceItem {
  final String placeId;
  final String name;
  final String formatted;
  final String addressLine1;
  final String addressLine2;
  final String? street;
  final String? houseNumber;
  final String? suburb;
  final String? city;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;
  final double? distance;
  final List<String> categories;
  final Map<String, dynamic> rawProperties;

  const GeoapifyPlaceItem({
    required this.placeId,
    required this.name,
    required this.formatted,
    required this.addressLine1,
    required this.addressLine2,
    this.street,
    this.houseNumber,
    this.suburb,
    this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
    this.distance,
    required this.categories,
    required this.rawProperties,
  });

  factory GeoapifyPlaceItem.fromFeature(Map<String, dynamic> feature) {
    final props = (feature['properties'] as Map<String, dynamic>?) ?? {};
    final geometry = (feature['geometry'] as Map<String, dynamic>?) ?? {};
    final coordinates = (geometry['coordinates'] as List<dynamic>?) ?? [];

    double lat = (props['lat'] as num?)?.toDouble() ?? 0.0;
    double lon = (props['lon'] as num?)?.toDouble() ?? 0.0;

    if (lat == 0.0 && lon == 0.0 && coordinates.length >= 2) {
      lon = (coordinates[0] as num).toDouble();
      lat = (coordinates[1] as num).toDouble();
    }

    final rawCategories = props['categories'] as List<dynamic>? ?? [];
    final categories = rawCategories.map((c) => c.toString()).toList();

    return GeoapifyPlaceItem(
      placeId: props['place_id'] as String? ?? '',
      name: props['name'] as String? ?? props['address_line1'] as String? ?? '',
      formatted: props['formatted'] as String? ?? '',
      addressLine1: props['address_line1'] as String? ?? '',
      addressLine2: props['address_line2'] as String? ?? '',
      street: props['street'] as String?,
      houseNumber: props['housenumber'] as String?,
      suburb: props['suburb'] as String? ?? props['neighbourhood'] as String?,
      city: props['city'] as String? ?? props['state'] as String?,
      state: props['state'] as String?,
      country: props['country'] as String?,
      latitude: lat,
      longitude: lon,
      distance: (props['distance'] as num?)?.toDouble(),
      categories: categories,
      rawProperties: props,
    );
  }

  /// Convierte el lugar a una sugerencia estándar para la barra de autocompletado
  PlacePrediction toPrediction() {
    final title = name.isNotEmpty ? name : addressLine1;
    final subtitle = addressLine2.isNotEmpty
        ? addressLine2
        : (city != null ? '$city, ${country ?? ""}' : formatted);

    return PlacePrediction(
      placeId: 'geoapify_${placeId}_${latitude}_$longitude',
      description: formatted.isNotEmpty ? formatted : title,
      mainText: title.isNotEmpty ? title : formatted,
      secondaryText: subtitle,
    );
  }
}

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

/// Servicio principal para interactuar con Geoapify:
/// - Places API v2 (`/v2/places`)
/// - Geocoding Autocomplete API (`/v1/geocode/autocomplete`)
/// - Reverse Geocoding API (`/v1/geocode/reverse`)
class GeoapifyService {
  final http.Client _client;
  final String _apiKey;

  GeoapifyService({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? GeoapifyConfig.apiKey;

  /// Limpia códigos Plus Code y sufijos de países redundantes
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
    // Remueve países al final para formato conciso y local
    clean = clean.replaceAll(RegExp(r',\s*Bolivia$', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r',\s*Argentina$', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r',\s*Germany$', caseSensitive: false), '');
    return clean.trim();
  }

  /// Formatea la dirección en su versión corta y concisa para el registro y perfil
  /// (ej: "Piedras 57", "Av. Belgrano 300", "Kaiser-Karl-Straße 4")
  static String toShortAddress(String raw) {
    final cleaned = cleanAddress(raw);
    if (cleaned.isEmpty) return raw.trim();
    final firstPart = cleaned.split(',').first.trim();
    return firstPart.isNotEmpty ? firstPart : cleaned;
  }

  /// Formatea dirección a partir de las propiedades devueltas por Geoapify
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

    // 3. Fallback al formateado oficial sin país al final
    if (formatted.isNotEmpty) {
      return cleanAddress(formatted);
    }

    return '';
  }

  // ==========================================
  // GEOAPIFY PLACES API v2 (`/v2/places`)
  // ==========================================

  /// Consulta lugares y puntos de interés (POI) utilizando Geoapify Places API v2.
  ///
  /// Parámetros:
  /// - [categories]: Categorías separadas por coma (ej. 'commercial.supermarket', 'catering.restaurant', 'commercial,catering,service')
  /// - [filter]: Filtro espacial geográfico (ej. 'rect:10.7164,48.7551,10.8353,48.6809' o 'circle:lon,lat,radiusMeters')
  /// - [bias]: Priorización geográfica suave (ej. 'proximity:lon,lat' o 'rect:...' o 'circle:...')
  /// - [name]: Búsqueda opcional por nombre del lugar (ej. 'Super', 'Banco', 'Hipermaxi')
  /// - [limit]: Cantidad máxima de resultados (por defecto 20)
  Future<List<GeoapifyPlaceItem>> getPlaces({
    String? categories,
    String? filter,
    String? bias,
    String? name,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'apiKey': _apiKey,
        'limit': limit.toString(),
      };

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }
      if (bias != null && bias.isNotEmpty) {
        queryParams['bias'] = bias;
      }
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final uri = Uri.parse(GeoapifyConfig.placesV2Url)
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        return features
            .map((f) => GeoapifyPlaceItem.fromFeature(f as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ==========================================
  // GEOAPIFY AUTOCOMPLETE & DETAILS
  // ==========================================

  /// Sugerencias de búsqueda con Geoapify Autocomplete
  /// Soporta búsqueda abierta y priorización (bias) por cercanía geográfica
  Future<List<PlacePrediction>> getAutocompletePredictions(
    String query, {
    double? biasLat,
    double? biasLng,
    String? countryCode,
    String? categories,
    int limit = 7,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    try {
      final queryParams = <String, String>{
        'text': clean,
        'apiKey': _apiKey,
        'lang': 'es',
        'limit': limit.toString(),
      };

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

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

        if (features.isNotEmpty) {
          return features.map((f) {
            final map = f as Map<String, dynamic>;
            final props = map['properties'] as Map<String, dynamic>? ?? {};

            final placeId = props['place_id'] as String? ?? '';
            final formatted = props['formatted'] as String? ?? '';
            final lat = props['lat']?.toString() ?? '0';
            final lon = props['lon']?.toString() ?? '0';

            final line1 = props['name'] as String? ??
                props['address_line1'] as String? ??
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
      }
    } catch (_) {}

    // Fallback: si no hubo resultados en autocomplete, intentar con Places API v2
    if (biasLat != null && biasLng != null) {
      try {
        final places = await getPlaces(
          categories: categories ?? 'commercial,catering,service,entertainment',
          filter: 'circle:$biasLng,$biasLat,10000',
          bias: 'proximity:$biasLng,$biasLat',
          name: clean,
          limit: limit,
        );
        if (places.isNotEmpty) {
          return places.map((p) => p.toPrediction()).toList();
        }
      } catch (_) {}
    }

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
        final finalAddr = address ?? '';
        return PlaceLocationResult(
          address: finalAddr,
          shortAddress: toShortAddress(finalAddr),
          latitude: lat,
          longitude: lng,
        );
      }
    }
    return null;
  }

  // ==========================================
  // GEOAPIFY REVERSE GEOCODING
  // ==========================================

  /// Geocodificación Inversa de Geoapify
  /// Convierte coordenadas (latitud, longitud) en el nombre legible de la dirección
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
}
