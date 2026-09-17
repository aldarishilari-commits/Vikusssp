import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 6: Contacto ("Registro del negocio_contacto-6.png")
class Step6ContactScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step6ContactScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step6ContactScreen> createState() => _Step6ContactScreenState();
}

class _Step6ContactScreenState extends State<Step6ContactScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.data.phoneNumber);
    _tiktokController = TextEditingController(text: widget.data.tiktok);
    _facebookController = TextEditingController(text: widget.data.facebook);
    _instagramController = TextEditingController(text: widget.data.instagram);
    _websiteController = TextEditingController(text: widget.data.website);

    _phoneController.addListener(() => widget.data.phoneNumber = _phoneController.text);
    _tiktokController.addListener(() => widget.data.tiktok = _tiktokController.text);
    _facebookController.addListener(() => widget.data.facebook = _facebookController.text);
    _instagramController.addListener(() => widget.data.instagram = _instagramController.text);
    _websiteController.addListener(() => widget.data.website = _websiteController.text);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
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
            progress: 0.60,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            '¿Como te pueden contactar\nlos clientes?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Agrega tus canales de comunicación.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4E4356),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WhatsApp Section
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chat_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WhatsApp',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Country Code box (+591)
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5E0EA),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+591',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Phone Number Input
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E0EA),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1B1C1C),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section: Redes sociales y página web (opcional)
                  Text(
                    'Redes sociales y página web (opcional)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // TikTok
                  Text(
                    'TikTok',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1C1C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSocialInput(_tiktokController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Facebook
                  Text(
                    'Facebook',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.facebook_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSocialInput(_facebookController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Instagram
                  Text(
                    'Instagram',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF833AB4),
                              Color(0xFFFD1D1D),
                              Color(0xFFFCB045),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSocialInput(_instagramController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Página web
                  Text(
                    'Página web',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildSocialInput(_websiteController),

                  const SizedBox(height: 16),
                ],
              ),
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

  Widget _buildSocialInput(TextEditingController controller) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E0EA),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF1B1C1C),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    );
  }
}
