import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pro_3d_icons.dart';

enum ProBenefitType {
  featuredProfile,
  unlimitedOffers,
  moreProducts,
}

class ProBenefitBottomSheet extends StatelessWidget {
  final ProBenefitType benefitType;

  const ProBenefitBottomSheet({super.key, required this.benefitType});

  static Future<void> show(BuildContext context, ProBenefitType type) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProBenefitBottomSheet(benefitType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = _getTitle();
    final description = _getDescription();
    final iconWidget = _getIconWidget();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Close Button Row (align right)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6D28D9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3D Graphic
              iconWidget,
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (benefitType) {
      case ProBenefitType.featuredProfile:
        return 'Perfil destacado';
      case ProBenefitType.unlimitedOffers:
        return 'Ofertas ilimitadas';
      case ProBenefitType.moreProducts:
        return 'Publica más productos\ny servicios';
    }
  }

  String _getDescription() {
    switch (benefitType) {
      case ProBenefitType.featuredProfile:
        return 'Tu negocio aparece primero y se resalta frente a perfiles gratuitos, aumentando visibilidad, consultas y clientes.';
      case ProBenefitType.unlimitedOffers:
        return 'Agrega tantas ofertas como quieras sobre tus productos o servicios.';
      case ProBenefitType.moreProducts:
        return 'Publica hasta 40 productos o servicios y muestra toda tu oferta a más clientes.';
    }
  }

  Widget _getIconWidget() {
    switch (benefitType) {
      case ProBenefitType.featuredProfile:
        return const Store3DIcon(size: 130, isLarge: true);
      case ProBenefitType.unlimitedOffers:
        return const DiscountTag3DIcon(size: 130, isLarge: true);
      case ProBenefitType.moreProducts:
        return const PackageBox3DIcon(size: 130, isLarge: true);
    }
  }
}
