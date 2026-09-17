import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header logo widget displaying the pin/store icon + "VikuS Pro" typography
class ProLogoHeader extends StatelessWidget {
  final double scale;

  const ProLogoHeader({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Map Pin + Store Icon
        Container(
          width: 38 * scale,
          height: 38 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E05FF), Color(0xFF6812C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E05FF).withOpacity(0.35),
                blurRadius: 10 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 22 * scale,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'VikuS ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26 * scale,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Pro',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26 * scale,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF8E05FF), Color(0xFFA832FF)],
                    ).createShader(const Rect.fromLTWH(0, 0, 80, 30)),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 3D-styled Storefront icon (for "Perfil destacado")
class Store3DIcon extends StatelessWidget {
  final double size;
  final bool isLarge;

  const Store3DIcon({super.key, this.size = 40, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    if (!isLarge) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    // Large 3D render for Modal BottomSheet
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient glow background
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E05FF).withOpacity(0.12),
            ),
          ),
          // 3D Shop Graphic
          Center(
            child: Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B21B6).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  const BoxShadow(
                    color: Color(0x40FFFFFF),
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Awning stripes
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: size * 0.22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA78BFA),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          5,
                          (index) => Container(
                            width: 8,
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFDDD6FE),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Shop window & bag
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: size * 0.15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Store Window
                          Container(
                            width: size * 0.26,
                            height: size * 0.26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDD6FE).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Color(0xFF6D28D9),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 3D Shopping bag
                          Container(
                            width: size * 0.22,
                            height: size * 0.28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_rounded,
                                color: Color(0xFFDDD6FE),
                                size: 16,
                              ),
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
        ],
      ),
    );
  }
}

/// 3D-styled Discount Tag icon (for "Ofertas ilimitadas")
class DiscountTag3DIcon extends StatelessWidget {
  final double size;
  final bool isLarge;

  const DiscountTag3DIcon({super.key, this.size = 40, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    if (!isLarge) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.discount_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    // Large 3D angled tag for Modal
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E05FF).withOpacity(0.12),
            ),
          ),
          Transform.rotate(
            angle: -math.pi / 6,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B21B6).withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: Color(0x40FFFFFF),
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Grommet / Punch hole at corner
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C1D95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDDD6FE),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Bold % symbol
                  Center(
                    child: Text(
                      '%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3D-styled Package Box icon (for "Publica más productos y servicios")
class PackageBox3DIcon extends StatelessWidget {
  final double size;
  final bool isLarge;

  const PackageBox3DIcon({super.key, this.size = 40, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    if (!isLarge) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    // Large 3D Container for Modal
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E05FF).withOpacity(0.12),
            ),
          ),
          Container(
            width: size * 0.70,
            height: size * 0.65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B21B6).withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Color(0x40FFFFFF),
                  blurRadius: 4,
                  offset: Offset(-2, -2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Box Lid Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: size * 0.16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA78BFA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                  ),
                ),
                // Handle slot in center
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: size * 0.24,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C1D95),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFDDD6FE).withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector / Matrix QR Code widget with center purple 'V' badge
class QrCodeDisplayWidget extends StatelessWidget {
  final double size;

  const QrCodeDisplayWidget({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size - 24, size - 24),
        painter: _QrMatrixPainter(),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'V',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()
      ..color = const Color(0xFF1B1C1C)
      ..style = PaintingStyle.fill;

    final cell = size.width / 21.0;

    // Helper to draw QR finder pattern (top-left, top-right, bottom-left)
    void drawFinderPattern(double startX, double startY) {
      // Outer 7x7
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, cell * 7, cell * 7),
          const Radius.circular(4),
        ),
        paintDark,
      );
      // Inner white 5x5
      final paintWhite = Paint()..color = Colors.white;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + cell, startY + cell, cell * 5, cell * 5),
          const Radius.circular(2),
        ),
        paintWhite,
      );
      // Center dot 3x3
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + cell * 2, startY + cell * 2, cell * 3, cell * 3),
          const Radius.circular(2),
        ),
        paintDark,
      );
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - cell * 7, 0);
    drawFinderPattern(0, size.height - cell * 7);

    // Decorative data grid
    final randomBits = [
      0x5A, 0xA5, 0x3C, 0xC3, 0x66, 0x99, 0xF0, 0x0F,
      0x55, 0xAA, 0x12, 0x89, 0x77, 0xEE, 0x4B, 0xB4,
      0x96, 0x69, 0x33, 0xCC, 0x88, 0x22, 0x5D, 0xD5,
    ];

    int bitIndex = 0;
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder areas
        if ((r < 8 && c < 8) ||
            (r < 8 && c > 12) ||
            (r > 12 && c < 8) ||
            (r >= 8 && r <= 12 && c >= 8 && c <= 12)) {
          continue;
        }

        final byte = randomBits[bitIndex % randomBits.length];
        final bit = (byte >> (c % 8)) & 1;
        bitIndex++;

        if (bit == 1 || (r % 2 == 0 && c % 3 == 0) || (r * c) % 5 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cell + 0.5, r * cell + 0.5, cell - 1.0, cell - 1.0),
              const Radius.circular(1.5),
            ),
            paintDark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Card logos widget (Visa & Mastercard)
class CardLogosWidget extends StatelessWidget {
  const CardLogosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Visa Logo Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            'VISA',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1A1F71),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Mastercard Logo Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFEB001B),
                  shape: BoxShape.circle,
                ),
              ),
              Transform.translate(
                offset: const Offset(-5, 0),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79E1B).withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
