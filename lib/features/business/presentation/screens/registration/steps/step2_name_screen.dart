import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/widgets/registration_shared_widgets.dart';

/// Pantalla 2: Nombre del negocio ("Registro del negocio_nombre-2.png")
class Step2NameScreen extends StatefulWidget {
  final BusinessRegistrationData data;
  final VoidCallback onExit;
  final VoidCallback onNext;

  const Step2NameScreen({
    super.key,
    required this.data,
    required this.onExit,
    required this.onNext,
  });

  @override
  State<Step2NameScreen> createState() => _Step2NameScreenState();
}

class _Step2NameScreenState extends State<Step2NameScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _descController = TextEditingController(text: widget.data.description);

    _nameController.addListener(() {
      widget.data.name = _nameController.text;
      setState(() {});
    });
    _descController.addListener(() {
      widget.data.description = _descController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Salir" & progress bar
          RegistrationHeader(
            buttonText: 'Salir',
            onExit: widget.onExit,
            progress: 0.20,
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            '¿Cómo se llama tu negocio?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Este nombre será visible para tus clientes.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4E4356),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: Nombre del negocio
                  Text(
                    'Nombre del negocio',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E0EA),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1B1C1C),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ej. Café Tuna',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFA09FA1),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Field 2: Descripción (opcional)
                  Row(
                    children: [
                      Text(
                        'Descripción ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                      Text(
                        '(opcional)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuentales a los usuarios que ofrece tu negocio.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E0EA),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1B1C1C),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Ej. Cafetería especialiada en café de altura y postres artesanales.',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFA09FA1),
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button: Continuar (full width)
          RegistrationBottomBar(
            onNext: widget.onNext,
            nextText: 'Continuar',
            isFullWidth: true,
            isNextEnabled: canContinue,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
