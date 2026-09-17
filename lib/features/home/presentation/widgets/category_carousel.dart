import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryItemModel {
  final String id;
  final String title;
  final String emoji;
  final IconData? icon;
  final Color? iconColor;

  const CategoryItemModel({
    required this.id,
    required this.title,
    this.emoji = '',
    this.icon,
    this.iconColor,
  });
}

class CategoryCarousel extends StatelessWidget {
  final ValueChanged<CategoryItemModel> onCategoryTap;

  const CategoryCarousel({
    super.key,
    required this.onCategoryTap,
  });

  static const List<CategoryItemModel> defaultCategories = [
    CategoryItemModel(
      id: 'comida',
      title: 'Comida',
      emoji: '🍔',
    ),
    CategoryItemModel(
      id: 'educacion',
      title: 'Educación',
      icon: Icons.school_rounded,
      iconColor: Color(0xFF1F2937),
    ),
    CategoryItemModel(
      id: 'salud',
      title: 'Salud',
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFEF4444),
    ),
    CategoryItemModel(
      id: 'entretenimiento',
      title: 'Entretenim...',
      icon: Icons.sports_esports_rounded,
      iconColor: Color(0xFFEC4899),
    ),
    CategoryItemModel(
      id: 'deporte',
      title: 'Deporte',
      icon: Icons.fitness_center_rounded,
      iconColor: Color(0xFF374151),
    ),
    CategoryItemModel(
      id: 'ver_mas',
      title: 'Ver más',
      icon: Icons.grid_view_rounded,
      iconColor: Color(0xFF6B7280),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: defaultCategories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final category = defaultCategories[index];

            return GestureDetector(
              onTap: () => onCategoryTap(category),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0x22000000) : const Color(0x0C000000),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: category.emoji.isNotEmpty
                        ? Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 24),
                          )
                        : Icon(
                            category.icon,
                            color: category.iconColor != null
                                ? (isDark && (category.iconColor == const Color(0xFF1F2937) || category.iconColor == const Color(0xFF374151))
                                    ? const Color(0xFFE5E7EB)
                                    : category.iconColor)
                                : (isDark ? const Color(0xFFC084FC) : AppColors.primary),
                            size: 24,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.title,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
