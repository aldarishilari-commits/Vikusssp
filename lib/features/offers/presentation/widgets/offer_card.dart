import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../data/models/offer_model.dart';
import 'offer_detail_bottom_sheet.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = FavoritesService.instance.isOfferFavorite(offer.id) || offer.isFavorite;

    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2836) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap ??
              () {
                OfferDetailBottomSheet.show(
                  context,
                  title: offer.title,
                  subtitle: offer.businessCategory,
                  businessName: offer.businessName,
                  businessCategory: offer.businessCategory,
                  price: 'Bs ${offer.discountedPrice.toInt()}',
                  originalPrice: 'Bs ${offer.originalPrice.toInt()}',
                  discountBadge: offer.discountBadge,
                  timerRemaining: offer.timeRemaining,
                  stockRemaining: offer.stockRemaining,
                  validUntil: offer.validUntil,
                  imageUrl: offer.imageUrl,
                  isFavorite: offer.isFavorite,
                  onFavoriteToggle: onFavoriteToggle,
                );
              },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // -------------------------------------------------------------
              // Image with Discount and Time Badges
              // -------------------------------------------------------------
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Image.network(
                        offer.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? const Color(0xFF2A2438) : const Color(0xFFF3E8FF),
                          child: Center(
                            child: Icon(
                              offer.categoryIcon,
                              size: 36,
                              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF8E05FF),
                            ),
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? const Color(0xFF231F2E) : const Color(0xFFF3F4F6),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Top-Left Discount Badge (-20%, -30%, etc.)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1B51),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33FF1B51),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        offer.discountBadge,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Time Remaining Badge (Clock icon + text)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11.5,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3.5),
                          Text(
                            offer.timeRemaining,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // -------------------------------------------------------------
              // Card Details
              // -------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon & Business Name
                    Row(
                      children: [
                        Icon(
                          offer.categoryIcon,
                          size: 14,
                          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7014F2),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            offer.businessName,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Offer Title
                    Text(
                      offer.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Prices: Original (strikethrough) and Discounted (bold purple)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Bs ${offer.originalPrice.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bs ${offer.discountedPrice.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7014F2),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location Distance & Favorite Heart Button
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          offer.distance,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (onFavoriteToggle != null) {
                              onFavoriteToggle!(!isFav);
                            } else {
                              FavoritesService.instance.toggleOfferFavorite(offer, context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 19,
                              color: isFav
                                  ? const Color(0xFFEF233C)
                                  : (isDark ? const Color(0xFFA78BFA) : const Color(0xFF8E05FF)),
                            ),
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
      ),
    );
  }
}
