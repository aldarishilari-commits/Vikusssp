import 'package:geolocator/geolocator.dart';

/// Servicio para gestionar la ubicación GPS del dispositivo y el cálculo de distancias
class LocationService {
  /// Solicita y verifica permisos de ubicación del dispositivo
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtiene la posición GPS actual del dispositivo
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Obtiene la posición GPS actual o una posición de referencia por defecto si no hay GPS/permisos
  static Future<Position> getUserPositionWithFallback({
    double fallbackLat = -16.5000,
    double fallbackLng = -68.1250,
  }) async {
    final pos = await getCurrentPosition();
    if (pos != null) return pos;

    return Position(
      latitude: fallbackLat,
      longitude: fallbackLng,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  /// Calcula la distancia en metros entre dos pares de coordenadas (fórmula Haversine en elipsoide WGS84)
  static double calculateDistanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Formatea la distancia calculada al formato estándar de Vikus (ej: "300 m de ti" o "1.2 km de ti")
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      // Redondear a múltiplos de 10 o 50 para visualización limpia
      final rounded = ((distanceInMeters / 10).round() * 10).clamp(10, 990);
      return '$rounded m de ti';
    } else {
      final inKm = distanceInMeters / 1000.0;
      return '${inKm.toStringAsFixed(1)} km de ti';
    }
  }

  /// Calcula y formatea directamente la distancia desde el usuario a un negocio
  static String getFormattedDistance({
    required double userLat,
    required double userLng,
    required double businessLat,
    required double businessLng,
  }) {
    final distance = calculateDistanceInMeters(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: businessLat,
      endLongitude: businessLng,
    );
    return formatDistance(distance);
  }
}
