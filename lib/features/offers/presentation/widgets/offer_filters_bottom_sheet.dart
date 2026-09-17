import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'offer_filter_dialog.dart';

/// Modal Bottom Sheet completo de filtros para la sección de Ofertas
class OfferFiltersBottomSheet extends StatefulWidget {
  final OfferFilterOptions initialOptions;
  final ValueChanged<OfferFilterOptions> onApply;

  const OfferFiltersBottomSheet({
    super.key,
    required this.initialOptions,
    required this.onApply,
  });

  /// Método estático conveniente para abrir el modal completo de filtros de ofertas
  static Future<void> show(
    BuildContext context, {
    required OfferFilterOptions initialOptions,
    required ValueChanged<OfferFilterOptions> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferFiltersBottomSheet(
        initialOptions: initialOptions,
        onApply: onApply,
      ),
    );
  }

  @override
  State<OfferFiltersBottomSheet> createState() => _OfferFiltersBottomSheetState();
}

class _OfferFiltersBottomSheetState extends State<OfferFiltersBottomSheet> {
  late String _expiration;
  late String _discount;
  late String _businessCategory;

  static const List<String> _expirationOptions = [
    'Todos',
    'Menos de 6 horas',
    'Menos de 24 horas',
    'Esta semana',
  ];

  static const List<String> _discountOptions = [
    'Todos',
    '15% o más',
    '20% o más',
    '25% o más',
    '30% o más',
    '40% o más',
  ];

  static const List<String> _businessOptions = [
    'Todos',
    'De los que sigues',
  ];

  @override
  void initState() {
    super.initState();
    _expiration = widget.initialOptions.selectedExpiration;
    _discount = widget.initialOptions.selectedDiscount;
    _businessCategory = widget.initialOptions.selectedBusinessCategory;
  }

  void _clearFilters() {
    setState(() {
      _expiration = 'Todos';
      _discount = 'Todos';
      _businessCategory = 'Todos';
    });
  }

  void _applyFilters() {
    final updated = OfferFilterOptions(
      selectedExpiration: _expiration,
      selectedDiscount: _discount,
      selectedBusinessCategory: _businessCategory,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark
            ? Border.all(color: const Color(0xFF2E2A38))
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x66000000) : const Color(0x26000000),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header: "Filtros de Ofertas" + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3B1E63) : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: Color(0xFF7014F2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Filtros',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF272430) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? const Color(0xFF2E2A38) : const Color(0xFFF3F4F6),
            ),

            // Scrollable Sections
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Vencimiento
                    _buildSectionTitle(
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Vencimiento',
                      subtitle: 'Filtra según el tiempo restante de la oferta',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _expirationOptions.map((opt) {
                        final isSelected = _expiration == opt;
                        return _buildOptionChip(
                          label: opt,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => setState(() => _expiration = opt),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Descuento
                    _buildSectionTitle(
                      icon: Icons.percent_rounded,
                      iconColor: const Color(0xFF8E05FF),
                      title: 'Porcentaje de descuento',
                      subtitle: 'Elige el nivel de rebaja mínimo',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _discountOptions.map((opt) {
                        final isSelected = _discount == opt;
                        return _buildOptionChip(
                          label: opt,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => setState(() => _discount = opt),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Negocios
                    _buildSectionTitle(
                      icon: Icons.storefront_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Negocios',
                      subtitle: 'Filtra por tus negocios seguidos o todos',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _businessOptions.map((opt) {
                        final isSelected = _businessCategory == opt;
                        return _buildOptionChip(
                          label: opt == 'Todos' ? 'Todos los negocios' : opt,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => setState(() => _businessCategory = opt),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Fixed Footer Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF2E2A38) : const Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Limpiar filtros
                  Expanded(
                    flex: 2,
                    child: TextButton(
                      onPressed: _clearFilters,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Limpiar filtros',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Aplicar filtros
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Aplicar filtros',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildSectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF4C1D95) : AppColors.primaryFixed)
        : (isDark ? const Color(0xFF272330) : Colors.white);
    final borderColor = isSelected
        ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
        : (isDark ? const Color(0xFF383344) : const Color(0xFFE5E7EB));
    final textColor = isSelected
        ? (isDark ? const Color(0xFFE9D5FF) : AppColors.primary)
        : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: textColor,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
