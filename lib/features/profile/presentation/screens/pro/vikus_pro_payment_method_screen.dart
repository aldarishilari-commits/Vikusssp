import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/vikus_pro_plan.dart';
import 'vikus_pro_card_payment_screen.dart';
import 'vikus_pro_qr_payment_screen.dart';

enum ProPaymentMethodType { qr, card }

class VikusProPaymentMethodScreen extends StatefulWidget {
  final VikusProPlan selectedPlan;

  const VikusProPaymentMethodScreen({
    super.key,
    required this.selectedPlan,
  });

  @override
  State<VikusProPaymentMethodScreen> createState() => _VikusProPaymentMethodScreenState();
}

class _VikusProPaymentMethodScreenState extends State<VikusProPaymentMethodScreen> {
  ProPaymentMethodType _selectedMethod = ProPaymentMethodType.qr;

  void _proceedToPayment() {
    if (_selectedMethod == ProPaymentMethodType.qr) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VikusProQrPaymentScreen(selectedPlan: widget.selectedPlan),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VikusProCardPaymentScreen(selectedPlan: widget.selectedPlan),
        ),
      );
    }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Elige cómo quieres pagar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona el método de pago que prefieres para continuar.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: QR Payment
              _buildPaymentOptionCard(
                type: ProPaymentMethodType.qr,
                iconWidget: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E05FF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: Color(0xFF7C3AED),
                      size: 24,
                    ),
                  ),
                ),
                title: 'QR',
                subtitle: 'Paga fácil desde tu app\nbancaria',
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Option 2: Card Payment
              _buildPaymentOptionCard(
                type: ProPaymentMethodType.card,
                iconWidget: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF272330) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                      size: 22,
                    ),
                  ),
                ),
                title: 'Tarjeta',
                subtitle: 'Débito o crédito\nVisa, Mastercard y más',
                isDark: isDark,
              ),

              const Spacer(),

              // Continuar al pago Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continuar al pago',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required ProPaymentMethodType type,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF271B3B) : const Color(0xFFF5F3FF))
              : (isDark ? const Color(0xFF1E1B24) : Colors.white),
          borderRadius: BorderRadius.circular(20),
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
              blurRadius: 10,
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

            // Icon
            iconWidget,
            const SizedBox(width: 14),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.3,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
