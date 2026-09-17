import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';

/// Pantalla 1: Inicio del registro ("Inicio del registro-1.png")
class Step1IntroScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step1IntroScreen({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Back Arrow
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFF1B1C1C),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Consigue más clientes\ncerca de ti',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Muestra tus productos, servicios y ofertas',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),

          const SizedBox(height: 48),

          // Benefits list
          _buildBenefitItem(
            iconWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFEA580C),
                  size: 24,
                ),
              ),
            ),
            text: 'Haz visible tu negocio',
          ),

          const SizedBox(height: 28),

          _buildBenefitItem(
            iconWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ),
            text: 'Conecta con clientes por WhatsApp\ny redes',
          ),

          const SizedBox(height: 28),

          _buildBenefitItem(
            iconWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
            ),
            text: 'Muestra lo que ofreces',
          ),

          const SizedBox(height: 28),

          _buildBenefitItem(
            iconWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
            ),
            text: 'Aumenta tus ventas con ofertas',
          ),

          const Spacer(),

          // Primary CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAlt,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Registrar mi negocio',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required Widget iconWidget,
    required String text,
  }) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
