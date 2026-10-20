/// Configuración de Geoapify API
class GeoapifyConfig {
  /// Clave de API de Geoapify para geocodificación inversa y autocompletado
  static const String apiKey = String.fromEnvironment(
    'GEOAPIFY_API_KEY',
    defaultValue: '2192259973ae4c41a4343fd8004ee9d1',
  );

  /// URL base de Geoapify API (raíz)
  static const String apiRoot = 'https://api.geoapify.com';

  /// URL base de Geoapify API v1
  static const String baseUrl = 'https://api.geoapify.com/v1';

  /// URL base de Geoapify Places API v2
  static const String placesV2Url = 'https://api.geoapify.com/v2/places';
}
