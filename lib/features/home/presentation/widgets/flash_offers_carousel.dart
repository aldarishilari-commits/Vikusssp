import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class FlashOfferModel {
  final String id;
  final String title;
  final String subtitle;
  final String storeName;
  final String distance;
  final String tag;
  final String expiryText;
  final String imageUrl;

  const FlashOfferModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.storeName,
    required this.distance,
    this.tag = 'OFERTA FLASH',
    this.expiryText = 'SOLO HOY',
    this.imageUrl = '',
  });
}

class FlashOffersCarousel extends StatefulWidget {
  final List<FlashOfferModel>? offers;
  final ValueChanged<FlashOfferModel>? onOfferTap;

  const FlashOffersCarousel({
    super.key,
    this.offers,
    this.onOfferTap,
  });

  @override
  State<FlashOffersCarousel> createState() => _FlashOffersCarouselState();
}

class _FlashOffersCarouselState extends State<FlashOffersCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentIndex = 0;

  static const List<FlashOfferModel> defaultOffers = [
    FlashOfferModel(
      id: 'offer_1',
      title: '2x1',
      subtitle: 'PIZZAS',
      storeName: 'Pizza Center',
      distance: 'A 300 m',
      tag: 'OFERTA FLASH',
      expiryText: 'SOLO HOY',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg',
    ),
    FlashOfferModel(
      id: 'offer_2',
      title: '2x1',
      subtitle: 'PIZZAS',
      storeName: 'Pizza Center',
      distance: 'A 300 m',
      tag: 'OFERTA FLASH',
      expiryText: 'SOLO HOY',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDa_GjJLeIkJpaN8Aq5F5gwAFE80r0L6l-4e3R0v2b4uMTgNAQYafhjr4kCyoH9ITj3n377qDs7FMrhg9TVYivy691f9XwS15nObZYssq5R8JomhyCK-Mo4wLPqFthSOdrBWQMc4_7djZn-pABc8MsYzk93dReSeLambeqJl7Y31VlJegBLi7AXEbzdhpmBJT3Dif5aSSXLw9QxSOFNYuNkIGNOqasEWTVW_f4EqrZSJMskF8s_aC3m3g',
    ),
    FlashOfferModel(
      id: 'offer_3',
      title: '30%',
      subtitle: 'HAMBURGUESAS',
      storeName: 'Burger Rock',
      distance: 'A 500 m',
      tag: 'PROMO FLASH',
      expiryText: 'HASTA 22:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBa_lzu6msUQhDmn4b8jiPIAl_Mbt2ppNQX3wm6R9F2hvLZsAbnx2hnyZMlH9H2tNNuhoHFPzoITFHXauAW15eiHKus6zIxcv59pZ0mXNXjUL4MQjsKvHNnoAXivbyqOY8edg7eV3v7FWvuOZ01xIU8N3AMyCpN64xUAr2zF0RWfVh3iTc24T_L0vmPbw880l1s1CYmJyV-nrp9gFs5RhEmSLKrU4FUDAPpQ6O56yXlsubGgg0Rm6Jnwg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.offers ?? defaultOffers;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Ofertas cerca de ti',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textMain,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Carousel Slider
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final offer = list[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => widget.onOfferTap?.call(offer),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB91C1C),
                          Color(0xFFDC2626),
                          Color(0xFFEF4444),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33DC2626),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Pizza / Food illustration in background right
                        Positioned(
                          right: -15,
                          top: -10,
                          bottom: -10,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 4,
                              ),
                            ),
                            child: ClipOval(
                              child: offer.imageUrl.isNotEmpty
                                  ? Image.network(
                                      offer.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => Container(
                                        color: const Color(0xFF7F1D1D),
                                        alignment: Alignment.center,
                                        child: const Text('🍕', style: TextStyle(fontSize: 50)),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF7F1D1D),
                                      alignment: Alignment.center,
                                      child: const Text('🍕', style: TextStyle(fontSize: 50)),
                                    ),
                            ),
                          ),
                        ),

                        // Offer Details
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Flash Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.flashYellow,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🔥', style: TextStyle(fontSize: 10)),
                                        const SizedBox(width: 3),
                                        Text(
                                          offer.tag,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.flashYellowText,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Main Big Offer Text
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        offer.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        offer.subtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFFEF08A),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Store info + Solo Hoy
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🍕', style: TextStyle(fontSize: 11)),
                                      const SizedBox(width: 4),
                                      Text(
                                        offer.storeName,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                      Text(
                                        offer.distance,
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '⏰ ${offer.expiryText}',
                                      style: GoogleFonts.inter(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFFEF08A),
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
            },
          ),
        ),

        // Dots Indicator
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(list.length, (index) {
              final bool isSelected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                      : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
