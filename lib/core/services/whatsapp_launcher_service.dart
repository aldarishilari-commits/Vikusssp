import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para abrir y dirigir al chat de WhatsApp del negocio registrado
class WhatsAppLauncherService {
  /// Limpia y formatea el número de teléfono con código de país internacional
  static String formatPhoneNumber({
    required String phoneNumber,
    String defaultCountryCode = '591',
  }) {
    // Eliminar caracteres no numéricos
    String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Si ya incluye el código de país (ej. 59170123456)
    if (digits.startsWith('591') && digits.length >= 10) {
      return digits;
    }

    // Si tiene 8 dígitos (celular boliviano típico), anteponer 591
    if (digits.length == 8) {
      final cleanPrefix = defaultCountryCode.replaceAll(RegExp(r'\D'), '');
      return '$cleanPrefix$digits';
    }

    return digits;
  }

  /// Abre directamente la app de WhatsApp o navegador con el chat del número registrado
  static Future<bool> openWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    String? businessName,
    String? customMessage,
  }) async {
    final cleanPhone = formatPhoneNumber(phoneNumber: phoneNumber);

    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este negocio aún no tiene un número de WhatsApp registrado.'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }

    // Mensaje inicial personalizado
    final message = customMessage ??
        (businessName != null && businessName.isNotEmpty
            ? '¡Hola $businessName! Los encontré en Vikus y quisiera hacer una consulta.'
            : '¡Hola! Encontré su negocio en Vikus y quisiera hacer una consulta.');

    final encodedText = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$cleanPhone?text=$encodedText';
    final uri = Uri.parse(urlString);

    try {
      // Intentar abrir mediante aplicación externa (WhatsApp nativo)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback a modo plataforma por defecto / navegador
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (e) {
      // Intentar esquema directo whatsapp:// como alternativa
      try {
        final directUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedText');
        return await launchUrl(directUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp en este dispositivo.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return false;
      }
    }
  }
}
