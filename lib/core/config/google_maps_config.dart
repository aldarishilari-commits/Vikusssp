/// Configuración de Google Maps y Google Places API
class GoogleMapsConfig {
  /// Clave de API de Google Cloud para servicios de Maps y Places
  /// Puede ser configurada en tiempo de compilación con --dart-define=MAPS_API_KEY=...
  static const String apiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyCK_xKmEUBWP2AxIilPBxXDvr-mjU80MFU',
  );

  /// Coordenadas por defecto (Centro de La Paz, Bolivia)
  static const double defaultLatitude = -16.5000;
  static const double defaultLongitude = -68.1250;
  static const double defaultZoom = 15.0;
}
