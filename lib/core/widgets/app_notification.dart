import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Notificaciones discretas, elegantes y flotantes para reemplazo de mensajes grandes/intrusivos.
class AppNotification {
  /// Muestra un mensaje flotante discreto de éxito (e.g., al agregar producto, servicio, oferta o negocio)
  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    _showFloatingMessage(
      context: context,
      message: message,
      icon: icon,
      iconColor: const Color(0xFF22C55E),
      backgroundColor: const Color(0xFF1E293B),
      duration: duration,
    );
  }

  /// Muestra un mensaje flotante informativo discreto
  static void showInfo(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    _showFloatingMessage(
      context: context,
      message: message,
      icon: icon,
      iconColor: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF1E293B),
      duration: duration,
    );
  }

  /// Muestra un mensaje flotante discreto de advertencia o error
  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _showFloatingMessage(
      context: context,
      message: message,
      icon: icon,
      iconColor: const Color(0xFFF87171),
      backgroundColor: const Color(0xFF1E293B),
      duration: duration,
    );
  }

  static void _showFloatingMessage({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: backgroundColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        duration: duration,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF8FAFC),
                  letterSpacing: -0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
