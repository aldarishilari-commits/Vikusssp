import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';

class ChangeEmailScreen extends StatefulWidget {
  final String currentEmail;
  final ValueChanged<String>? onEmailUpdated;

  const ChangeEmailScreen({
    super.key,
    this.currentEmail = 'aldarisguzman@gmail.com',
    this.onEmailUpdated,
  });

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  // Step 0: Input Form, Step 1: Verification Sent, Step 2: Email Updated Success
  int _currentStep = 0;
  final _newEmailController = TextEditingController();
  bool _isLoading = false;
  String _pendingEmail = '';

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }

  void _submitNewEmail() async {
    final email = _newEmailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un correo electrónico válido'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (email.toLowerCase() == widget.currentEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nuevo correo no puede ser igual al actual'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _pendingEmail = email;
    });

    try {
      await AuthService().updateEmail(newEmail: email);
      if (!mounted) return;

      widget.onEmailUpdated?.call(_pendingEmail);

      setState(() {
        _isLoading = false;
        _currentStep = 1;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _simulateVerifyEmail() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    widget.onEmailUpdated?.call(_pendingEmail);

    setState(() {
      _isLoading = false;
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textMain,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Correo electronico',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStepWidget(isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildInputStep(isDark);
      case 1:
        return _buildVerificationSentStep(isDark);
      case 2:
        return _buildSuccessStep(isDark);
      default:
        return _buildInputStep(isDark);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 0: Input Form (Screen 3 of Stitch reference)
  // ---------------------------------------------------------------------------
  Widget _buildInputStep(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Email (Read-only)
          Text(
            'Correo electronico actual',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
            ),
            child: Text(
              widget.currentEmail,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // New Email
          Text(
            'Nuevo correo electronico',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textMain,
              ),
              decoration: InputDecoration(
                hintText: 'Ingresa tu nuevo correo',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Purple Info Notice Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C223D) : const Color(0xFFF3E8FF).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFE9D5FF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Te enviaremos un enlace de verificación a tu correo electrónico',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Primary CTA: Guardar cambios
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitNewEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Guardar cambios',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Verification Email Sent (Screen 4 of Stitch reference)
  // ---------------------------------------------------------------------------
  Widget _buildVerificationSentStep(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(1),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Big Envelope Icon with check badge
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.darkBackground : Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Enlace de verificación enviado',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Te enviamos un enlace a\n$_pendingEmail',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Revisa tu bandeja de entrada y haz click en el enlace para verificar tu nuevo correo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // Primary CTA: Ir a mi correo (Simulates verification)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _simulateVerifyEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Ir a mi correo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Secondary CTA: Entendido, volver al perfil
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido, volver al perfil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Email Updated Success (Screen 5 of Stitch reference)
  // ---------------------------------------------------------------------------
  Widget _buildSuccessStep(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(2),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Green Check Circle
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3300C853),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Correo actualizado',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Tu correo electrónico ha sido actualizado correctamente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),

          // CTA: Volver al perfil
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Volver al perfil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
