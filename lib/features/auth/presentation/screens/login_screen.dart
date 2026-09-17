import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String bgImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBDCVZuHW95Pr33W_0aCMdP5EgYqXuMAWJ0p7VQTCRgXY9cb0mCt45qCIgzjYstgafMryjJOvlSrRhlze6hN7PyS8GsJF65fFdTY8qqnw0OQoFLwOxmW2q1dWMwdNiPHWukLvGeuVgbBoLncmj28Ui_xZVBK0aCyzdAaocYrF45UU43w8I69BmvXiuQA-a6CMMH4EBfnzlZIJmevF6YfXrMwU-aS4Xu1F9FTGagKz0tj4Nfe0g3LDgNgmT7w3Tn2-Xc_I4';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final response = await AuthService().signInWithGoogle();
      if (response == null) {
        // El usuario canceló la selección de cuenta
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ¡Inicio de sesión con Google exitoso! Bienvenido a Vikus.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(title: 'Vikus'),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, acepta los términos y condiciones para continuar.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // Registro de usuario en Supabase
        await AuthService().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 ¡Cuenta creada con éxito! Bienvenido a Vikus.'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        // Inicio de sesión en Supabase
        await AuthService().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👋 ¡Bienvenido de nuevo a Vikus!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(title: 'Vikus'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Recuperar contraseña',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: AppColors.textMain,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: resetEmailController,
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      if (email.isEmpty || !email.contains('@')) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Por favor ingresa un correo válido.'),
                            backgroundColor: Color(0xFFDC2626),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);
                      try {
                        await AuthService().resetPassword(email: email);
                        if (!mounted) return;
                        navigator.pop();
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('📩 Enlace de recuperación enviado. Revisa tu bandeja de entrada.'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setDialogState(() => isSending = false);
                        final msg = e.toString().replaceAll('Exception:', '').trim();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Enviar',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Street Image (Upper Section)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  LoginScreen.bgImageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: const Color(0xFFF6F4F9));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF6F4F9),
                      child: const Icon(Icons.apartment_rounded, size: 80, color: AppColors.primary),
                    );
                  },
                ),
                // Gradient overlay to fade into white form
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x88FFFFFF),
                        Colors.white,
                      ],
                      stops: [0.30, 0.65, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Safe Area for Back Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        color: AppColors.textMain,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Container at Bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Segmented Switch: Iniciar Sesión / Registrarse
                      Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: !_isSignUp ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !_isSignUp
                                        ? const [
                                            BoxShadow(
                                              color: Color(0x0A000000),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Iniciar sesión',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: !_isSignUp ? FontWeight.w800 : FontWeight.w600,
                                        color: !_isSignUp ? AppColors.primary : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _isSignUp ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _isSignUp
                                        ? const [
                                            BoxShadow(
                                              color: Color(0x0A000000),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Crear cuenta',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: _isSignUp ? FontWeight.w800 : FontWeight.w600,
                                        color: _isSignUp ? AppColors.primary : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Fields: Nombre Completo & Teléfono
                      if (_isSignUp) ...[
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Nombre completo',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (_isSignUp && (value == null || value.trim().isEmpty)) {
                              return 'Por favor ingresa tu nombre completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Teléfono celular (opcional)',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa tu email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Por favor ingresa un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password Link (Solo visible en Iniciar Sesión)
                      if (!_isSignUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: AppTypography.link,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Submit Button
                      PrimaryButton(
                        text: _isSignUp ? 'Crear cuenta' : 'Iniciar sesión',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: 16),

                      // Divider "o continúa con"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'o continúa con',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In Button
                      _buildGoogleButton(),
                      const SizedBox(height: 16),

                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: const BorderSide(
                                color: Color(0xFF9CA3AF),
                                width: 1.5,
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: Text(
                                'He leído y acepto los términos y condiciones',
                                style: AppTypography.bodySM.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isGoogleLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGoogleLogo(),
                      const SizedBox(width: 12),
                      Text(
                        _isSignUp ? 'Registrarse con Google' : 'Continuar con Google',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    // Google G colorful pie slices
    final pathBlue = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0, 1.25, false)
      ..close();
    canvas.drawPath(pathBlue, bluePaint);

    final pathGreen = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 1.25, 1.35, false)
      ..close();
    canvas.drawPath(pathGreen, greenPaint);

    final pathYellow = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 2.60, 1.20, false)
      ..close();
    canvas.drawPath(pathYellow, yellowPaint);

    final pathRed = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 3.80, 1.45, false)
      ..close();
    canvas.drawPath(pathRed, redPaint);

    // Inner cutout
    final innerWhite = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, innerWhite);

    // Blue horizontal bar
    final barRect = Rect.fromLTWH(center.dx, center.dy - (radius * 0.20), radius * 0.95, radius * 0.40);
    canvas.drawRect(barRect, bluePaint);

    // Cutout top right wedge
    final cutoutPaint = Paint()..color = Colors.white;
    final cutoutRect = Rect.fromLTWH(center.dx, center.dy - radius, radius, radius * 0.8);
    canvas.drawRect(cutoutRect, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
