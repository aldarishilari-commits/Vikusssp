import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String currentCity;
  final VoidCallback onLocationTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.currentCity,
    required this.onLocationTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City Selector Chip / Button
          InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFC084FC).withValues(alpha: 0.2)
                          : AppColors.primaryFixed.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentCity,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Notification Bell Button
          IconButton(
            onPressed: onNotificationTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No tienes notificaciones pendientes'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white : AppColors.textMain,
              size: 26,
            ),
            splashRadius: 24,
            tooltip: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}
