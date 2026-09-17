import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 8: Foto del negocio ("Registro del negocio_foto-8.png")
class Step8PhotoScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step8PhotoScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step8PhotoScreen> createState() => _Step8PhotoScreenState();
}

class _Step8PhotoScreenState extends State<Step8PhotoScreen> {
  void _addMockPhoto() {
    setState(() {
      widget.data.photoUrls.add(
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto agregada correctamente'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = widget.data.photoUrls.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RegistrationHeader(
            buttonText: 'Guardar y salir',
            onExit: widget.onExit,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            '¿Quieres agregar fotos de tu\nnegocio?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 32),

          // Photo Upload Box
          GestureDetector(
            onTap: _addMockPhoto,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E0EA),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hasPhotos
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            widget.data.photoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.data.photoUrls.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF1B1C1C),
                                width: 2.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1B1C1C),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const Spacer(),

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
