import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import 'business_card_item.dart';
import 'package:aeronpulse/features/business/presentation/widgets/business_schedule_bottom_sheet.dart';

class BusinessDetailBottomSheet extends StatefulWidget {
  final BusinessModel business;
  final ValueChanged<bool>? onFavoriteToggle;

  const BusinessDetailBottomSheet({
    super.key,
    required this.business,
    this.onFavoriteToggle,
  });

  static void show(
    BuildContext context, {
    required BusinessModel business,
    ValueChanged<bool>? onFavoriteToggle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessDetailBottomSheet(
        business: business,
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }

  @override
  State<BusinessDetailBottomSheet> createState() => _BusinessDetailBottomSheetState();
}

class _BusinessDetailBottomSheetState extends State<BusinessDetailBottomSheet> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.instance.isBusinessFavorite(widget.business.id) || widget.business.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Hero Image with Floating Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        b.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? const Color(0xFF272430) : const Color(0xFFFEF3C7),
                          child: Icon(b.categoryIcon, size: 50, color: const Color(0xFFD97706)),
                        ),
                      ),
                    ),
                  ),

                  // Close Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),

                  // Status Badge (Live & Interactive)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => BusinessScheduleBottomSheet.show(context, b),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: b.isCurrentlyOpenNow ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              b.isCurrentlyOpenNow
                                  ? 'Abierto · ${b.scheduleStatusSubtitle}'
                                  : 'Cerrado · ${b.scheduleStatusSubtitle}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Promo Badge (if any)
                  if (b.promoBadge != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          b.promoBadge!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Info Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3B1D66) : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(b.categoryIcon, size: 14, color: isDark ? const Color(0xFFC084FC) : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              b.category,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFE9D5FF) : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFEB700), size: 20),
                          const SizedBox(width: 3),
                          Text(
                            b.rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                            ),
                          ),
                          Text(
                            ' (${b.reviewsCount} reseñas)',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Business Name
                  Text(
                    b.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Distance and Address
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        '${b.address} • ${b.distance}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    b.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Highlights Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF272330) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHighlightItem(Icons.verified_rounded, 'Verificado', 'Negocio Seguro', isDark),
                        _buildHighlightItem(Icons.bolt_rounded, 'Atención', 'Rápida', isDark),
                        _buildHighlightItem(Icons.local_shipping_rounded, 'Envíos', 'Disponibles', isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Bottom Action Bar: WhatsApp & Favorite
                  Row(
                    children: [
                      // Favorite Toggle Button
                      GestureDetector(
                        onTap: () {
                          final newFav = FavoritesService.instance.toggleBusinessFavorite(b, context);
                          setState(() {
                            _isFavorite = newFav;
                          });
                          widget.onFavoriteToggle?.call(newFav);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isFavorite
                                ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2))
                                : (isDark ? const Color(0xFF272330) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isFavorite
                                  ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                                  : (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Icon(
                            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: _isFavorite ? const Color(0xFFEF233C) : (isDark ? Colors.white : const Color(0xFF4B5563)),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // WhatsApp Direct Contact Button
                      Expanded(
                        child: WhatsAppButton(
                          phoneNumber: b.phoneNumber,
                          businessName: b.name,
                          label: 'WhatsApp',
                          height: 50,
                          borderRadius: 16,
                          onBeforeLaunch: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(IconData icon, String title, String subtitle, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? const Color(0xFFC084FC) : AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
