import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Plataformas sociales y canales web soportados
enum SocialPlatform {
  facebook,
  tiktok,
  instagram,
  website,
}

/// Servicio integral para formatear y abrir enlaces de redes sociales y páginas web
class SocialLauncherService {
  /// Normaliza y formatea el enlace o handle según la plataforma indicada
  static String formatSocialUrl({
    required SocialPlatform platform,
    required String rawValue,
  }) {
    final clean = rawValue.trim();
    if (clean.isEmpty) return '';

    switch (platform) {
      case SocialPlatform.facebook:
        if (clean.startsWith('http://') || clean.startsWith('https://')) {
          return clean;
        }
        if (clean.startsWith('facebook.com') ||
            clean.startsWith('www.facebook.com') ||
            clean.startsWith('fb.com') ||
            clean.startsWith('m.facebook.com')) {
          return 'https://$clean';
        }
        final handle = clean.startsWith('@') ? clean.substring(1) : clean;
        return 'https://www.facebook.com/$handle';

      case SocialPlatform.tiktok:
        if (clean.startsWith('http://') || clean.startsWith('https://')) {
          return clean;
        }
        if (clean.startsWith('tiktok.com') ||
            clean.startsWith('www.tiktok.com') ||
            clean.startsWith('m.tiktok.com')) {
          return 'https://$clean';
        }
        final handle = clean.startsWith('@') ? clean : '@$clean';
        return 'https://www.tiktok.com/$handle';

      case SocialPlatform.instagram:
        if (clean.startsWith('http://') || clean.startsWith('https://')) {
          return clean;
        }
        if (clean.startsWith('instagram.com') ||
            clean.startsWith('www.instagram.com')) {
          return 'https://$clean';
        }
        final handle = clean.startsWith('@') ? clean.substring(1) : clean;
        return 'https://www.instagram.com/$handle';

      case SocialPlatform.website:
        if (clean.startsWith('http://') || clean.startsWith('https://')) {
          return clean;
        }
        return 'https://$clean';
    }
  }

  /// Retorna el nombre legible de la plataforma
  static String getPlatformLabel(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.website:
        return 'Página Web';
    }
  }

  /// Abre el enlace o perfil correspondiente en el navegador o app externa
  static Future<bool> openSocial({
    required BuildContext context,
    required SocialPlatform platform,
    required String rawValue,
    String? businessName,
  }) async {
    final label = getPlatformLabel(platform);
    final urlString = formatSocialUrl(platform: platform, rawValue: rawValue);

    if (urlString.isEmpty) {
      if (context.mounted) {
        final bizPrefix = businessName != null && businessName.isNotEmpty
            ? '"$businessName"'
            : 'Este negocio';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$bizPrefix aún no tiene un enlace de $label registrado.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF6B7280),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El enlace de $label no tiene un formato válido.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    try {
      // 1. Intentar abrir en la aplicación externa nativa
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // 2. Fallback a plataforma / navegador web
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (_) {
      try {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir $label en este dispositivo.'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return false;
      }
    }
  }

  /// Atajo para abrir Facebook
  static Future<bool> openFacebook(
    BuildContext context,
    String rawValue, {
    String? businessName,
  }) {
    return openSocial(
      context: context,
      platform: SocialPlatform.facebook,
      rawValue: rawValue,
      businessName: businessName,
    );
  }

  /// Atajo para abrir TikTok
  static Future<bool> openTikTok(
    BuildContext context,
    String rawValue, {
    String? businessName,
  }) {
    return openSocial(
      context: context,
      platform: SocialPlatform.tiktok,
      rawValue: rawValue,
      businessName: businessName,
    );
  }

  /// Atajo para abrir Instagram
  static Future<bool> openInstagram(
    BuildContext context,
    String rawValue, {
    String? businessName,
  }) {
    return openSocial(
      context: context,
      platform: SocialPlatform.instagram,
      rawValue: rawValue,
      businessName: businessName,
    );
  }

  /// Atajo para abrir Sitio Web
  static Future<bool> openWebsite(
    BuildContext context,
    String rawValue, {
    String? businessName,
  }) {
    return openSocial(
      context: context,
      platform: SocialPlatform.website,
      rawValue: rawValue,
      businessName: businessName,
    );
  }
}
