import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/business_filter_criteria.dart';
import 'business_filters_bottom_sheet.dart';

/// Barra horizontal de chips de filtros rápidos (Filtros(1).png)
class QuickFilterChips extends StatelessWidget {
  final BusinessFilterCriteria criteria;
  final ValueChanged<BusinessFilterCriteria> onCriteriaChanged;

  const QuickFilterChips({
    super.key,
    required this.criteria,
    required this.onCriteriaChanged,
  });

  void _openFullFilters(BuildContext context) {
    BusinessFiltersBottomSheet.show(
      context,
      initialCriteria: criteria,
      onApply: (newCriteria) {
        onCriteriaChanged(newCriteria);
      },
    );
  }

  void _openDistanceFilter(BuildContext context) {
    DistanceFilterBottomSheet.show(
      context,
      initialDistance: criteria.maxDistanceKm,
      onApply: (newDist) {
        if (newDist == null) {
          onCriteriaChanged(criteria.copyWith(clearMaxDistance: true));
        } else {
          onCriteriaChanged(criteria.copyWith(maxDistanceKm: newDist));
        }
      },
    );
  }

  void _openPriceFilter(BuildContext context) {
    PriceFilterBottomSheet.show(
      context,
      initialPrices: criteria.selectedPrices,
      onApply: (newPrices) {
        onCriteriaChanged(criteria.copyWith(selectedPrices: newPrices));
      },
    );
  }

  void _toggleOnlyOpen() {
    onCriteriaChanged(criteria.copyWith(onlyOpen: !criteria.onlyOpen));
  }

  void _toggleOnlyOffers() {
    onCriteriaChanged(criteria.copyWith(onlyOffers: !criteria.onlyOffers));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDistanceActive = criteria.maxDistanceKm != null;
    final bool isPricesActive = criteria.selectedPrices.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          // Filter 1: Filtros (Abre modal completo)
          _buildChip(
            context: context,
            label: criteria.activeFilterCount > 0
                ? 'Filtros (${criteria.activeFilterCount})'
                : 'Filtros',
            icon: Icons.tune_rounded,
            iconColor: criteria.hasActiveFilters
                ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
            isSelected: criteria.hasActiveFilters,
            badgeCount: criteria.activeFilterCount > 0
                ? criteria.activeFilterCount
                : null,
            onTap: () => _openFullFilters(context),
          ),
          const SizedBox(width: 8),

          // Filter 2: Distancia (Abre modal de distancia)
          _buildChip(
            context: context,
            label: isDistanceActive
                ? '${criteria.maxDistanceKm!.toStringAsFixed(1)} km'
                : 'Distancia',
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFEF4444),
            isSelected: isDistanceActive,
            onTap: () => _openDistanceFilter(context),
          ),
          const SizedBox(width: 8),

          // Filter 3: Abierto (Toggle rápido)
          _buildChip(
            context: context,
            label: 'Abierto',
            customLeading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: criteria.onlyOpen
                    ? const Color(0xFF16A34A)
                    : AppColors.statusOpen,
                shape: BoxShape.circle,
              ),
            ),
            isSelected: criteria.onlyOpen,
            activeBgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
            activeBorderColor: const Color(0xFF10B981),
            activeTextColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            onTap: _toggleOnlyOpen,
          ),
          const SizedBox(width: 8),

          // Filter 4: Ofertas (Toggle rápido)
          _buildChip(
            context: context,
            label: 'Ofertas',
            customLeading: const Text('🔥', style: TextStyle(fontSize: 12)),
            isSelected: criteria.onlyOffers,
            activeBgColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
            activeBorderColor: const Color(0xFFF59E0B),
            activeTextColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            onTap: _toggleOnlyOffers,
          ),
          const SizedBox(width: 8),

          // Filter 5: Precio (Abre modal de precio)
          _buildChip(
            context: context,
            label: isPricesActive
                ? 'Precio (${criteria.selectedPrices.map((p) => p.shortSymbol).join('')})'
                : 'Precio',
            icon: Icons.attach_money_rounded,
            iconColor: const Color(0xFF10B981),
            isSelected: isPricesActive,
            onTap: () => _openPriceFilter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    IconData? icon,
    Color? iconColor,
    Widget? customLeading,
    required bool isSelected,
    int? badgeCount,
    Color? activeBgColor,
    Color? activeBorderColor,
    Color? activeTextColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSelected
        ? (activeBgColor ?? (isDark ? const Color(0xFF4C1D95) : AppColors.primaryFixed))
        : (isDark ? const Color(0xFF1E1B24) : Colors.white);
    final borderColor = isSelected
        ? (activeBorderColor ?? (isDark ? const Color(0xFFC084FC) : AppColors.primary))
        : (isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB));
    final textColor = isSelected
        ? (activeTextColor ?? (isDark ? const Color(0xFFE9D5FF) : AppColors.primary))
        : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
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
              if (customLeading != null) ...[
                customLeading,
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? textColor
                      : (iconColor ?? (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
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
