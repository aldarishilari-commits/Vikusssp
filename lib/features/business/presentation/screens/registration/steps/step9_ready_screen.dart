import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/core/theme/app_colors.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 9: Información del negocio ("Registro del negocio_9.png")
class Step9ReadyScreen extends StatelessWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenProducts;
  final VoidCallback onFinish;

  const Step9ReadyScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onOpenServices,
    required this.onOpenProducts,
    required this.onFinish,
  });

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
            onExit: onExit,
          ),

          const SizedBox(height: 36),

          // Action 1: Agrega servicios
          GestureDetector(
            onTap: onOpenServices,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 30,
                    color: Color(0xFF1B1C1C),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Agrega servicios',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  if (data.services.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAlt.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${data.services.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAlt,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: Color(0xFF4B5563),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Action 2: Agrega productos
          GestureDetector(
            onTap: onOpenProducts,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 30,
                    color: Color(0xFF1B1C1C),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Agrega productos',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  if (data.products.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAlt.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${data.products.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAlt,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: Color(0xFF4B5563),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Party Popper Graphic and "¡Listo!"
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Party Popper Illustration
                const SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _PartyCelebrationPainter(),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  '¡Listo!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Tu negocio ya está\nlisto para publicar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // Bottom Bar with "Terminar"
          RegistrationBottomBar(
            onBack: onBack,
            onNext: onFinish,
            nextText: 'Terminar',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Dibuja con precisión la ilustración de celebración y cono de confeti
class _PartyCelebrationPainter extends CustomPainter {
  const _PartyCelebrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Confetti dots/squares
    void drawDot(double dx, double dy, Color color, double radius) {
      final p = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(dx, dy), width: radius * 2, height: radius * 2),
          const Radius.circular(2),
        ),
        p,
      );
    }

    drawDot(size.width * 0.25, size.height * 0.20, const Color(0xFF0284C7), 4);
    drawDot(size.width * 0.65, size.height * 0.15, const Color(0xFF0369A1), 3.5);
    drawDot(size.width * 0.82, size.height * 0.35, const Color(0xFF0F766E), 4);
    drawDot(size.width * 0.78, size.height * 0.65, const Color(0xFF059669), 4);
    drawDot(size.width * 0.85, size.height * 0.78, const Color(0xFF1E293B), 3.5);
    drawDot(size.width * 0.50, size.height * 0.08, const Color(0xFFF59E0B), 3);

    // 2. Ribbons
    final blueRibbonPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final ribbon1 = Path()
      ..moveTo(size.width * 0.35, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.15,
        size.width * 0.52,
        size.height * 0.25,
      );
    canvas.drawPath(ribbon1, blueRibbonPaint);

    final orangeRibbonPaint = Paint()
      ..color = const Color(0xFFEA580C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final ribbon2 = Path()
      ..moveTo(size.width * 0.62, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.35,
        size.width * 0.70,
        size.height * 0.22,
      );
    canvas.drawPath(ribbon2, orangeRibbonPaint);

    // 3. Yellow Party Cone
    final conePath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.85)
      ..lineTo(size.width * 0.72, size.height * 0.48)
      ..lineTo(size.width * 0.45, size.height * 0.30)
      ..close();

    final coneBasePaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawPath(conePath, coneBasePaint);

    // Stripes on Cone
    final stripePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.72),
      Offset(size.width * 0.54, size.height * 0.38),
      stripePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.44, size.height * 0.80),
      Offset(size.width * 0.62, size.height * 0.45),
      stripePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
