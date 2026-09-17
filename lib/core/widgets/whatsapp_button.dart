import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/whatsapp_launcher_service.dart';

/// Botón estilizado de WhatsApp que coincide exactamente con el diseño oficial de Vikus
class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String? businessName;
  final String? customMessage;
  final String label;
  final double height;
  final double borderRadius;
  final double fontSize;
  final VoidCallback? onBeforeLaunch;

  const WhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.businessName,
    this.customMessage,
    this.label = 'WhatsApp',
    this.height = 48,
    this.borderRadius = 18,
    this.fontSize = 15,
    this.onBeforeLaunch,
  });

  void _handleTap(BuildContext context) {
    onBeforeLaunch?.call();
    WhatsAppLauncherService.openWhatsApp(
      context: context,
      phoneNumber: phoneNumber,
      businessName: businessName,
      customMessage: customMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: const Color(0xFF16A34A), // Verde WhatsApp vibrante oficial
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: 0,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono circular de WhatsApp con borde blanco
                _buildWhatsAppLogo(),
                const SizedBox(width: 10),
                // Texto en blanco con tipografía destacada
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppLogo() {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 23,
          height: 23,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.phone_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ),
    );
  }
}
