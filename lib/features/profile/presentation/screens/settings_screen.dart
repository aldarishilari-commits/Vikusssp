import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/theme_service.dart';
import 'appearance_screen.dart';
import 'change_password_screen.dart';
import 'notifications_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToBusinessTab;

  const SettingsScreen({
    super.key,
    required this.onLogout,
    this.onNavigateToBusinessTab,
  });

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          '¿Cerrar sesión?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
        content: Text(
          'Podrás volver a ingresar con tu cuenta en cualquier momento.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(BuildContext context, {required String title, required String content, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C223D) : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isDark ? const Color(0xFFC084FC) : AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBillingModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderLight : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C223D) : const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: isDark ? const Color(0xFFC084FC) : AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  'Pagos y Facturación',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF272330) : const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? const Color(0xFF3F3B48) : const Color(0xFFF3E8FF)),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 36, color: isDark ? const Color(0xFFC084FC) : AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Método preferido: QR Simple',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF581C87),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pagos directos y seguros sin comisiones extra.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Aceptar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
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
          'Configuración',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // SECCIÓN 1: CUENTA
              // ---------------------------------------------------------------
              _buildSectionTitle('Cuenta', isDark: isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                children: [
                  _buildSettingsRow(
                    icon: Icons.lock_rounded,
                    title: 'Cambiar contraseña',
                    isFirst: true,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark: isDark),
                  _buildSettingsRow(
                    icon: Icons.notifications_rounded,
                    title: 'Notificaciones',
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark: isDark),
                  ListenableBuilder(
                    listenable: ThemeService.instance,
                    builder: (context, _) {
                      return _buildSettingsRow(
                        icon: Icons.palette_rounded,
                        title: 'Apariencia',
                        trailingText: ThemeService.instance.currentThemeMode.label,
                        isLast: true,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // SECCIÓN 2: GESTIÓN
              // ---------------------------------------------------------------
              _buildSectionTitle('Gestión', isDark: isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                children: [
                  _buildSettingsRow(
                    icon: Icons.storefront_rounded,
                    title: 'Mis negocios',
                    isFirst: true,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToBusinessTab?.call();
                    },
                  ),
                  _buildDivider(isDark: isDark),
                  _buildSettingsRow(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Pagos y facturación',
                    isLast: true,
                    isDark: isDark,
                    onTap: () => _showBillingModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // SECCIÓN 3: PRIVACIDAD Y SEGURIDAD
              // ---------------------------------------------------------------
              _buildSectionTitle('Privacidad y seguridad', isDark: isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                children: [
                  _buildSettingsRow(
                    icon: Icons.shield_rounded,
                    title: 'Términos y condiciones',
                    isFirst: true,
                    isDark: isDark,
                    onTap: () => _showInfoModal(
                      context,
                      title: 'Términos y condiciones',
                      icon: Icons.shield_rounded,
                      content: 'Al usar Vikus / Aeronpulse aceptas nuestras políticas de conexión local y trato directo con comercios de tu ciudad.',
                    ),
                  ),
                  _buildDivider(isDark: isDark),
                  _buildSettingsRow(
                    icon: Icons.description_rounded,
                    title: 'Política de privacidad',
                    isLast: true,
                    isDark: isDark,
                    onTap: () => _showInfoModal(
                      context,
                      title: 'Política de privacidad',
                      icon: Icons.description_rounded,
                      content: 'Tus datos personales y de contacto se encuentran protegidos y nunca serán vendidos ni cedidos a terceras empresas.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // SECCIÓN 4: AYUDA
              // ---------------------------------------------------------------
              _buildSectionTitle('Ayuda', isDark: isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                children: [
                  _buildSettingsRow(
                    icon: Icons.help_outline_rounded,
                    title: 'Centro de ayuda',
                    isFirst: true,
                    isDark: isDark,
                    onTap: () => _showInfoModal(
                      context,
                      title: 'Centro de ayuda',
                      icon: Icons.help_outline_rounded,
                      content: 'Encuentra respuestas a preguntas frecuentes sobre publicación de ofertas, seguimiento de negocios y contacto directo.',
                    ),
                  ),
                  _buildDivider(isDark: isDark),
                  _buildSettingsRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Contactar soporte',
                    isLast: true,
                    isDark: isDark,
                    onTap: () => _showInfoModal(
                      context,
                      title: 'Soporte Vikus',
                      icon: Icons.support_agent_rounded,
                      content: 'Escríbenos directamente por WhatsApp o a soporte@vikus.app para asistirte de inmediato con cualquier consulta.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // SECCIÓN 5: CERRAR SESIÓN
              // ---------------------------------------------------------------
              _buildCardContainer(
                isDark: isDark,
                children: [
                  _buildSettingsRow(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Cerrar sesión',
                    isFirst: true,
                    isLast: true,
                    isDark: isDark,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isDark}) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : AppColors.textMain,
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children, required bool isDark}) {
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider({required bool isDark}) {
    return Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6));
  }

  Widget _buildSettingsRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final effectiveIconColor = iconColor ?? (isDark ? const Color(0xFFC084FC) : const Color(0xFF1B1C1C));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: effectiveIconColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
            ],
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
