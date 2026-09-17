import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';

/// Barra superior de navegación del registro con botón "Guardar y salir" o "Salir"
/// y barra de progreso morada.
class RegistrationHeader extends StatelessWidget {
  final String buttonText;
  final VoidCallback onExit;
  final double? progress; // 0.0 to 1.0 (null if no progress bar)

  const RegistrationHeader({
    super.key,
    this.buttonText = 'Guardar y salir',
    required this.onExit,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onExit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E0EA),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 18),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBF5),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress!.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Barra inferior con botón "Atrás" a la izquierda y botón de acción morado a la derecha.
class RegistrationBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextText;
  final bool showBack;
  final bool isNextEnabled;
  final bool isFullWidth;

  const RegistrationBottomBar({
    super.key,
    this.onBack,
    required this.onNext,
    this.nextText = 'Siguiente',
    this.showBack = true,
    this.isNextEnabled = true,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isNextEnabled ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAlt,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryAlt.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            nextText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBack)
          GestureDetector(
            onTap: onBack,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Atrás',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 40),
        ElevatedButton(
          onPressed: isNextEnabled ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAlt,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryAlt.withValues(alpha: 0.5),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            nextText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Selector de tipo de oferta (Sin oferta vs Oferta flash)
class OfferTypeSelector extends StatelessWidget {
  final bool isFlashOffer;
  final ValueChanged<bool> onChanged;

  const OfferTypeSelector({
    super.key,
    required this.isFlashOffer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sin oferta
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !isFlashOffer ? const Color(0xFFFAF5FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !isFlashOffer
                      ? AppColors.primaryAlt
                      : const Color(0xFFE5E0EA),
                  width: !isFlashOffer ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !isFlashOffer
                            ? AppColors.primaryAlt
                            : const Color(0xFFA09FA1),
                        width: 1.5,
                      ),
                    ),
                    child: !isFlashOffer
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryAlt,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      'Sin oferta',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Oferta Flash
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFlashOffer ? const Color(0xFFFAF5FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFlashOffer
                      ? AppColors.primaryAlt
                      : const Color(0xFFE5E0EA),
                  width: isFlashOffer ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFlashOffer
                            ? AppColors.primaryAlt
                            : const Color(0xFFA09FA1),
                        width: 1.5,
                      ),
                    ),
                    child: isFlashOffer
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryAlt,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oferta flash',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Descuento por tiempo corto (horas)',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF6B7280),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Selector de días de la semana con chips (Lun, Mar, Miér, Jue, Vier, Sab, Dom)
class DaysOfWeekSelector extends StatelessWidget {
  final List<String> selectedDays;
  final ValueChanged<List<String>> onChanged;

  const DaysOfWeekSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const List<String> days = [
    'Lun',
    'Mar',
    'Miér',
    'Jue',
    'Vier',
    'Sab',
    'Dom',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selectedDays);
            if (isSelected) {
              updated.remove(day);
            } else {
              updated.add(day);
            }
            onChanged(updated);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryAlt : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryAlt
                    : const Color(0xFFE5E0EA),
                width: 1,
              ),
            ),
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4E4356),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Campo numérico con flechas arriba/abajo (Stepper)
class NumberStepperField extends StatelessWidget {
  final TextEditingController controller;
  final String? prefixText;
  final String? hintText;
  final double step;
  final bool isInteger;

  const NumberStepperField({
    super.key,
    required this.controller,
    this.prefixText,
    this.hintText,
    this.step = 1.0,
    this.isInteger = false,
  });

  void _increment() {
    double current = double.tryParse(controller.text) ?? 0.0;
    current += step;
    controller.text = isInteger ? current.toInt().toString() : current.toStringAsFixed(1);
  }

  void _decrement() {
    double current = double.tryParse(controller.text) ?? 0.0;
    if (current >= step) {
      current -= step;
      controller.text = isInteger ? current.toInt().toString() : current.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E0EA),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (prefixText != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 6),
              child: Text(
                prefixText!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1B1C1C),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFA09FA1),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixText != null ? 0 : 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _increment,
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
                GestureDetector(
                  onTap: _decrement,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
