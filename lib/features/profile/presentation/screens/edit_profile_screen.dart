import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'change_email_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final ValueChanged<String>? onProfileUpdated;
  final void Function(String name, String phone, String email)? onSaved;

  const EditProfileScreen({
    super.key,
    this.initialName = 'Aldaris Guzmán',
    this.initialPhone = '78946546',
    this.initialEmail = 'aldarisguzman@gmail.com',
    this.onProfileUpdated,
    this.onSaved,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late String _currentEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _currentEmail = widget.initialEmail;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await ProfileService().getCurrentProfile();
    if (mounted && profile != null) {
      setState(() {
        if (profile.fullName.isNotEmpty) _nameController.text = profile.fullName;
        if (profile.phone != null && profile.phone!.isNotEmpty) _phoneController.text = profile.phone!;
        if (profile.email.isNotEmpty) _currentEmail = profile.email;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _openChangeEmail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeEmailScreen(
          currentEmail: _currentEmail,
          onEmailUpdated: (newEmail) {
            setState(() {
              _currentEmail = newEmail;
            });
            widget.onProfileUpdated?.call(_nameController.text.trim());
            widget.onSaved?.call(
              _nameController.text.trim(),
              _phoneController.text.trim(),
              newEmail,
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ProfileService().updateProfile(
        fullName: newName,
        phone: newPhone,
      );

      widget.onProfileUpdated?.call(newName);
      widget.onSaved?.call(newName, newPhone, _currentEmail);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado con éxito ✨'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Editar perfil',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actualiza tu información personal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Campo: Nombre completo
              _buildEditableCardField(
                label: 'Nombre completo',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF6B7280),
                controller: _nameController,
                hintText: 'Ingresa tu nombre completo',
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Campo: Teléfono celular
              _buildEditableCardField(
                label: 'Teléfono celular',
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFF7C3AED),
                controller: _phoneController,
                hintText: 'Número de contacto',
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Campo: E-mail (Tapping opens email change flow)
              _buildNavigationCardField(
                label: 'E-mail',
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFF7C3AED),
                value: _currentEmail,
                isDark: isDark,
                onTap: _openChangeEmail,
              ),
              const SizedBox(height: 24),

              // Banner: Tu información está segura
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C223D) : const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFF3E8FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu información está segura',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF581C87),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'No compartimos tu información personal con terceros.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón Guardar cambios
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: const Icon(Icons.save_rounded, size: 20, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Guardar cambios',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCardField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x05000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? const Color(0xFFC084FC) : iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    hintText: hintText,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.edit_rounded,
            size: 18,
            color: Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCardField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x33000000) : const Color(0x05000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? const Color(0xFFC084FC) : iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
