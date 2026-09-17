import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OffersStep extends StatelessWidget {
  const OffersStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 3D Mockup Graphic
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [
                  Color(0xFFF6F0FF),
                  Color(0xFFEDF0F7),
                  Color(0xFFE5EAF2),
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Phone frame mockup
                Container(
                  width: 220,
                  height: 320,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111317),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xCCD1D5DB), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x338E05FF),
                        blurRadius: 30,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Bar mock
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '9:41',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.wifi, size: 10, color: Color(0xFF1E293B)),
                                SizedBox(width: 4),
                                Icon(Icons.battery_full, size: 10, color: Color(0xFF1E293B)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ofertas cerca',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Featured Offer Card inside mockup
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8822EE), Color(0xFF6812C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x406812C7),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEB700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '50% OFF',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF332000),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Promoción especial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'En restaurantes seleccionados',
                                style: TextStyle(
                                  color: Color(0xFFE9D5FF),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Mini promo items
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.local_pizza_rounded, size: 16, color: Color(0xFFF97316)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Pizza 2x1 Martes',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                '-30%',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating 3D Discount Bag (Bottom Right)
                Positioned(
                  right: 32,
                  bottom: 40,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8C2BE2), Color(0xFF5D0FBD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x665D0FBD),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Tag
                        Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            width: 32,
                            height: 38,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(radius: 2, backgroundColor: Color(0xFF5D0FBD)),
                                SizedBox(height: 2),
                                Text(
                                  '%',
                                  style: TextStyle(
                                    color: Color(0xFF5D0FBD),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Fire Icon Badge (Bottom Center)
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2B8E05FF),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Text Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Encuentra ofertas\ncerca de ti',
                textAlign: TextAlign.center,
                style: AppTypography.headlineXL,
              ),
              const SizedBox(height: 12),
              Text(
                'Aprovecha las mejores promociones y\ndescuentos todos los días.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMD,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
