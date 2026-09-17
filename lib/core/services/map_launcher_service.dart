import 'package:url_launcher/url_launcher.dart';

/// Servicio para abrir ubicaciones en la app nativa de Google Maps o navegador web
class MapLauncherService {
  /// Abre Google Maps con las coordenadas del negocio
  static Future<bool> openMapWithCoordinates(double latitude, double longitude) async {
    final urlString = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (_) {
      return false;
    }
  }
}
