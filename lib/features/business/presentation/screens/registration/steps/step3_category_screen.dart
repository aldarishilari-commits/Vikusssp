import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 3: Categoría ("Registro_negocio_categoria-3.png")
class Step3CategoryScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step3CategoryScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step3CategoryScreen> createState() => _Step3CategoryScreenState();
}

class _Step3CategoryScreenState extends State<Step3CategoryScreen> {
  late String _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Restaurantes y\ncomida',
      'categoryKey': 'Restaurantes y comida',
      'icon': Icons.restaurant_rounded,
    },
    {
      'title': 'Cafeterias y\nbebidas',
      'categoryKey': 'Cafeterias y bebidas',
      'icon': Icons.coffee_rounded,
    },
    {
      'title': 'Educación',
      'categoryKey': 'Educación',
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Belleza y salud',
      'categoryKey': 'Belleza y salud',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'Ropa y moda',
      'categoryKey': 'Ropa y moda',
      'icon': Icons.checkroom_rounded,
    },
    {
      'title': 'Deportes y ocio',
      'categoryKey': 'Deportes y ocio',
      'icon': Icons.sports_esports_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.data.category.isNotEmpty
        ? widget.data.category
        : 'Restaurantes y comida';
  }

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      widget.data.category = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RegistrationHeader(
            buttonText: 'Guardar y salir',
            onExit: widget.onExit,
            progress: 0.35,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            'Selecciona la categoria de\ntu negocio',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Elige la que mejor te describa lo que\nofreces',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4E4356),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 24),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final item = _categories[index];
                final isSelected = _selectedCategory == item['categoryKey'];

                return GestureDetector(
                  onTap: () => _selectCategory(item['categoryKey'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFAF5FF)
                          : const Color(0xFFFAF9F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryAlt
                            : const Color(0xFFE5E0EA),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: isSelected
                              ? AppColors.primaryAlt
                              : const Color(0xFF374151),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryAlt
                                : const Color(0xFF374151),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Bar
          RegistrationBottomBar(
            onBack: widget.onBack,
            onNext: widget.onNext,
            nextText: 'Siguiente',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
