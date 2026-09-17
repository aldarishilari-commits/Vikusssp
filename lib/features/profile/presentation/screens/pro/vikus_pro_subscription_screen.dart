import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/vikus_pro_plan.dart';
import 'vikus_pro_payment_method_screen.dart';
import 'widgets/pro_3d_icons.dart';
import 'widgets/pro_benefit_bottom_sheet.dart';

class VikusProSubscriptionScreen extends StatefulWidget {
  const VikusProSubscriptionScreen({super.key});

  @override
  State<VikusProSubscriptionScreen> createState() => _VikusProSubscriptionScreenState();
}

class _VikusProSubscriptionScreenState extends State<VikusProSubscriptionScreen> {
  VikusProPlan _selectedPlan = VikusProPlan.availablePlans.first;

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VikusProPaymentMethodScreen(selectedPlan: _selectedPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFBF9F8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              const Center(
                child: ProLogoHeader(scale: 1.05),
              ),
              const SizedBox(height: 24),

              // Title "¿Por qué unirme a Pro?"
              Text(
                '¿Por qué unirme a Pro?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 14),

              // Benefit 1: Perfil destacado
              _buildBenefitRow(
                icon: const Store3DIcon(size: 38),
                title: 'Perfil destacado',
                isDark: isDark,
                onTap: () => ProBenefitBottomSheet.show(
                  context,
                  ProBenefitType.featuredProfile,
                ),
              ),
              const SizedBox(height: 10),

              // Benefit 2: Ofertas ilimitadas
              _buildBenefitRow(
                icon: const DiscountTag3DIcon(size: 38),
                title: 'Ofertas ilimitadas',
                isDark: isDark,
                onTap: () => ProBenefitBottomSheet.show(
                  context,
                  ProBenefitType.unlimitedOffers,
                ),
              ),
              const SizedBox(height: 10),

              // Benefit 3: Publica más productos y servicios
              _buildBenefitRow(
                icon: const PackageBox3DIcon(size: 38),
                title: 'Publica más productos\ny servicios',
                isDark: isDark,
                onTap: () => ProBenefitBottomSheet.show(
                  context,
                  ProBenefitType.moreProducts,
                ),
              ),
              const SizedBox(height: 26),

              // Plan selection list
              Column(
                children: VikusProPlan.availablePlans.map((plan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPlanSelectionCard(
                      plan: plan,
                      isSelected: _selectedPlan.id == plan.id,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Continuar Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required Widget icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B24) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x04000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelectionCard({
    required VikusProPlan plan,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF271B3B) : const Color(0xFFF5F3FF))
              : (isDark ? const Color(0xFF1E1B24) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : (isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF7C3AED).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7C3AED)
                      : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                  width: isSelected ? 6 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),

            // Plan Title & Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.periodLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Badge if available
            if (plan.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.isPopular
                      ? const Color(0xFF7C3AED)
                      : (isDark ? const Color(0xFF3F2B5C) : const Color(0xFFEDE9FE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.badge!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: plan.isPopular
                        ? Colors.white
                        : (isDark ? const Color(0xFFDDD6FE) : const Color(0xFF6D28D9)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
