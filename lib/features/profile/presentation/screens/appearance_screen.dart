import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/theme_service.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final currentMode = ThemeService.instance.currentThemeMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.textMain,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
            title: Text(
              'Apariencia',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textMain,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personaliza la apariencia de la app en tu dispositivo según tus preferencias.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card Container with theme options
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0x33000000) : const Color(0x06000000),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildThemeOption(
                          context: context,
                          mode: AppThemeMode.system,
                          isFirst: true,
                          isLast: false,
                          isDarkUi: isDark,
                          isSelected: currentMode == AppThemeMode.system,
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
                        ),
                        _buildThemeOption(
                          context: context,
                          mode: AppThemeMode.light,
                          isFirst: false,
                          isLast: false,
                          isDarkUi: isDark,
                          isSelected: currentMode == AppThemeMode.light,
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
                        ),
                        _buildThemeOption(
                          context: context,
                          mode: AppThemeMode.dark,
                          isFirst: false,
                          isLast: true,
                          isDarkUi: isDark,
                          isSelected: currentMode == AppThemeMode.dark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Live Preview Section
                  Text(
                    'Vista previa en tiempo real',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildLivePreviewCard(isDark, currentMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required AppThemeMode mode,
    required bool isFirst,
    required bool isLast,
    required bool isDarkUi,
    required bool isSelected,
  }) {
    return InkWell(
      key: Key('theme_option_${mode.name}'),
      onTap: () async {
        await ThemeService.instance.setThemeMode(mode);
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(mode.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Tema ${mode.label} activado',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1400),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkUi ? const Color(0xFF2C223D) : const Color(0xFFF5EEFD))
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDarkUi ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                mode.icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDarkUi ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected
                          ? (isDarkUi ? const Color(0xFFC084FC) : AppColors.primary)
                          : (isDarkUi ? Colors.white : const Color(0xFF1B1C1C)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mode.description,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDarkUi ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDarkUi ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de previsualización en vivo de la apariencia seleccionada
  Widget _buildLivePreviewCard(bool isDark, AppThemeMode currentMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vikus Marketplace',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textMain,
                        ),
                      ),
                      Text(
                        'Modo actual: ${currentMode.label}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C223D) : const Color(0xFFF5EEFD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF8C4FF6) : const Color(0xFFD8B4FE),
                  ),
                ),
                child: Text(
                  'Activo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Botón Principal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Secundario',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
