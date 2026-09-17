import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfferFilterOptions {
  final String selectedExpiration;
  final String selectedDiscount;
  final String selectedBusinessCategory;

  const OfferFilterOptions({
    this.selectedExpiration = 'Todos',
    this.selectedDiscount = 'Todos',
    this.selectedBusinessCategory = 'Todos',
  });

  bool get hasActiveFilters =>
      selectedExpiration != 'Todos' ||
      selectedDiscount != 'Todos' ||
      selectedBusinessCategory != 'Todos';

  int get activeCount {
    int count = 0;
    if (selectedExpiration != 'Todos') count++;
    if (selectedDiscount != 'Todos') count++;
    if (selectedBusinessCategory != 'Todos') count++;
    return count;
  }

  OfferFilterOptions copyWith({
    String? selectedExpiration,
    String? selectedDiscount,
    String? selectedBusinessCategory,
  }) {
    return OfferFilterOptions(
      selectedExpiration: selectedExpiration ?? this.selectedExpiration,
      selectedDiscount: selectedDiscount ?? this.selectedDiscount,
      selectedBusinessCategory: selectedBusinessCategory ?? this.selectedBusinessCategory,
    );
  }

  OfferFilterOptions clone() {
    return OfferFilterOptions(
      selectedExpiration: selectedExpiration,
      selectedDiscount: selectedDiscount,
      selectedBusinessCategory: selectedBusinessCategory,
    );
  }
}

class OfferFilterDialog extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const OfferFilterDialog({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  static void showOptions({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfferFilterDialog(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelected: (val) {
          Navigator.pop(ctx);
          onSelected(val);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).padding.bottom > 0 ? 8 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 14),

              // Options List
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((opt) {
                      final isSelected = opt == selectedValue;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onSelected(opt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2C223D) : const Color(0xFFF3E8FF))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF7014F2) : const Color(0xFF8E05FF))
                                  : (isDark ? const Color(0xFF2E2A38) : const Color(0xFFF3F4F6)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                opt,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFFE9D5FF) : const Color(0xFF7014F2))
                                      : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7014F2),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
