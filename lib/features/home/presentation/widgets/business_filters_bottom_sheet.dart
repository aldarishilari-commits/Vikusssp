import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/business_filter_criteria.dart';

/// Modal Bottom Sheet completo de filtros (Filtros(1).png - Pantalla 5)
class BusinessFiltersBottomSheet extends StatefulWidget {
  final BusinessFilterCriteria initialCriteria;
  final ValueChanged<BusinessFilterCriteria> onApply;

  const BusinessFiltersBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  /// Método estático conveniente para abrir el modal completo
  static Future<void> show(
    BuildContext context, {
    required BusinessFilterCriteria initialCriteria,
    required ValueChanged<BusinessFilterCriteria> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BusinessFiltersBottomSheet(
        initialCriteria: initialCriteria,
        onApply: onApply,
      ),
    );
  }

  @override
  State<BusinessFiltersBottomSheet> createState() =>
      _BusinessFiltersBottomSheetState();
}

class _BusinessFiltersBottomSheetState
    extends State<BusinessFiltersBottomSheet> {
  late double? _distance;
  late bool _onlyOpen;
  late bool _onlyOffers;
  late Set<PriceLevel> _selectedPrices;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialCriteria.maxDistanceKm;
    _onlyOpen = widget.initialCriteria.onlyOpen;
    _onlyOffers = widget.initialCriteria.onlyOffers;
    _selectedPrices = Set.from(widget.initialCriteria.selectedPrices);
  }

  void _clearFilters() {
    setState(() {
      _distance = null;
      _onlyOpen = false;
      _onlyOffers = false;
      _selectedPrices.clear();
    });
  }

  void _applyFilters() {
    final updatedCriteria = BusinessFilterCriteria(
      maxDistanceKm: _distance,
      onlyOpen: _onlyOpen,
      onlyOffers: _onlyOffers,
      selectedPrices: _selectedPrices,
    );
    widget.onApply(updatedCriteria);
    Navigator.of(context).pop();
  }

  void _togglePrice(PriceLevel level) {
    setState(() {
      if (_selectedPrices.contains(level)) {
        _selectedPrices.remove(level);
      } else {
        _selectedPrices.add(level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55000000) : const Color(0x26000000),
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
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header: "Filtros" + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
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

            Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Distancia
                    Text(
                      'Distancia máxima',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Slider de Distancia
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                        trackHeight: 5,
                        thumbColor: AppColors.primary,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                          elevation: 3,
                        ),
                        overlayColor: AppColors.primary.withValues(alpha: 0.15),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                      ),
                      child: Slider(
                        value: _distance ?? 5.0,
                        min: 0.5,
                        max: 5.0,
                        divisions: 9,
                        onChanged: (value) {
                          setState(() {
                            _distance = value;
                          });
                        },
                      ),
                    ),

                    // Etiquetas de Distancia
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0.5 km',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3B1D66)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _distance == null
                                  ? 'Cualquier distancia'
                                  : (_distance! >= 5.0
                                      ? 'Hasta 5+ km'
                                      : 'Hasta ${_distance!.toStringAsFixed(1)} km'),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '5 km',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Estado del negocio
                    Text(
                      'Estado del negocio',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF272330) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 19,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Abierto ahora',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                          Switch(
                            value: _onlyOpen,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF22C55E),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: isDark ? AppColors.darkBorderLight : const Color(0xFFD1D5DB),
                            onChanged: (val) {
                              setState(() {
                                _onlyOpen = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Ofertas
                    Text(
                      'Ofertas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF272330) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('🔥', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Solo con ofertas',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                          Switch(
                            value: _onlyOffers,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: isDark ? AppColors.darkBorderLight : const Color(0xFFD1D5DB),
                            onChanged: (val) {
                              setState(() {
                                _onlyOffers = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 4: Precio
                    Text(
                      'Precio',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: PriceLevel.values.map((level) {
                        final isSelected = _selectedPrices.contains(level);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => _togglePrice(level),
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF272330) : Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    level.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563)),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Footer Action Buttons: "Limpiar filtros" & "Aplicar filtros"
                    Row(
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
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Rápido de Distancia (Filtros(1).png - Pantalla 3)
class DistanceFilterBottomSheet extends StatefulWidget {
  final double? initialDistance;
  final ValueChanged<double?> onApply;

  const DistanceFilterBottomSheet({
    super.key,
    required this.initialDistance,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required double? initialDistance,
    required ValueChanged<double?> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DistanceFilterBottomSheet(
        initialDistance: initialDistance,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DistanceFilterBottomSheet> createState() =>
      _DistanceFilterBottomSheetState();
}

class _DistanceFilterBottomSheetState
    extends State<DistanceFilterBottomSheet> {
  late double? _distance;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header: "Distancia" + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distancia máxima',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
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
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                trackHeight: 5,
                thumbColor: AppColors.primary,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 3,
                ),
              ),
              child: Slider(
                value: _distance ?? 5.0,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                onChanged: (val) {
                  setState(() => _distance = val);
                },
              ),
            ),

            // Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0.5 km',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3B1D66)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _distance == null
                          ? 'Cualquier distancia'
                          : (_distance! >= 5.0
                              ? 'Hasta 5+ km'
                              : 'Hasta ${_distance!.toStringAsFixed(1)} km'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '5 km',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _distance = null;
                      });
                    },
                    child: Text(
                      'Limpiar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_distance);
                      Navigator.of(context).pop();
                    },
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
          ],
        ),
      ),
    );
  }
}

/// Modal Rápido de Precio (Filtros(1).png - Pantalla 4)
class PriceFilterBottomSheet extends StatefulWidget {
  final Set<PriceLevel> initialPrices;
  final ValueChanged<Set<PriceLevel>> onApply;

  const PriceFilterBottomSheet({
    super.key,
    required this.initialPrices,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required Set<PriceLevel> initialPrices,
    required ValueChanged<Set<PriceLevel>> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PriceFilterBottomSheet(
        initialPrices: initialPrices,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PriceFilterBottomSheet> createState() => _PriceFilterBottomSheetState();
}

class _PriceFilterBottomSheetState extends State<PriceFilterBottomSheet> {
  late Set<PriceLevel> _selectedPrices;

  @override
  void initState() {
    super.initState();
    _selectedPrices = Set.from(widget.initialPrices);
  }

  void _togglePrice(PriceLevel level) {
    setState(() {
      if (_selectedPrices.contains(level)) {
        _selectedPrices.remove(level);
      } else {
        _selectedPrices.add(level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header: "Precio" + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
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
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pills de Precio
            Row(
              children: PriceLevel.values.map((level) {
                final isSelected = _selectedPrices.contains(level);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _togglePrice(level),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF272330) : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            level.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563)),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPrices.clear();
                      });
                    },
                    child: Text(
                      'Limpiar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedPrices);
                      Navigator.of(context).pop();
                    },
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
          ],
        ),
      ),
    );
  }
}
