import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CitySelectorBottomSheet extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const CitySelectorBottomSheet({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  static const List<String> cities = [
    'La Paz',
    'Pando',
    'El Alto',
    'Santa Cruz',
    'Cochabamba',
  ];

  static Future<String?> show(
    BuildContext context, {
    required String currentCity,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitySelectorBottomSheet(
        selectedCity: currentCity,
        onCitySelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55000000) : const Color(0x26000000),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderLight : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with Title & Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar ciudad',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textMain,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Elige la ciudad donde quieres buscar negocios locales.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF272430) : const Color(0xFF4B5563),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick GPS / Current Location Option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onCitySelected('La Paz');
                Navigator.of(context).pop('La Paz');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ubicación detectada: La Paz'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF272330) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1D66) : AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usar mi ubicación actual',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Detectar tu ciudad automáticamente',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textGrey,
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
          const SizedBox(height: 20),

          // Available Cities Section Header
          Text(
            'Ciudades disponibles',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Cities List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final city = cities[index];
              final bool isSelected = city.toLowerCase() == selectedCity.toLowerCase();

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onCitySelected(city);
                    Navigator.of(context).pop(city);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF3B1D66) : AppColors.primaryFixed.withValues(alpha: 0.45))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppColors.primary : AppColors.primaryFixed)
                                    : (isDark ? const Color(0xFF272430) : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: isSelected
                                    ? (isDark ? Colors.white : AppColors.primary)
                                    : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              city,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? Colors.white : AppColors.textMain)
                                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF374151)),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBorderLight : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
