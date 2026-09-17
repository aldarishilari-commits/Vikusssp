import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _allNotifications = true;
  bool _newOffers = true;
  bool _expiringOffers = true;
  bool _importantMessages = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final profile = await ProfileService().getCurrentProfile();
    if (mounted && profile != null) {
      setState(() {
        _allNotifications = profile.notifyAll;
        _newOffers = profile.notifyNewOffers;
        _expiringOffers = profile.notifyExpiringOffers;
        _importantMessages = profile.notifyImportantMessages;
      });
    }
  }

  void _savePreferences() {
    ProfileService().updateNotificationPreferences(
      notifyAll: _allNotifications,
      notifyNewOffers: _newOffers,
      notifyExpiringOffers: _expiringOffers,
      notifyImportantMessages: _importantMessages,
    );
  }

  void _toggleAll(bool value) {
    setState(() {
      _allNotifications = value;
      _newOffers = value;
      _expiringOffers = value;
      _importantMessages = value;
    });
    _savePreferences();
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
          'Notificaciones',
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
              // Master Switch Card
              _buildSingleToggleCard(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFF22C55E),
                title: 'Activar todas las notificaciones',
                subtitle: 'Desactiva o activa todas las notificaciones de la app.',
                value: _allNotifications,
                isDark: isDark,
                onChanged: _toggleAll,
              ),
              const SizedBox(height: 24),

              // Section 1: OFERTAS DE NEGOCIOS QUE SIGUES
              _buildSectionHeader('OFERTAS DE NEGOCIOS QUE SIGUES', isDark: isDark),
              const SizedBox(height: 8),
              Container(
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
                  children: [
                    _buildSwitchRow(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFF22C55E),
                      title: 'Nuevas ofertas',
                      subtitle: 'Recibe cuando los negocios que sigues publiquen nuevas ofertas.',
                      value: _newOffers,
                      isDark: isDark,
                      onChanged: (val) {
                        setState(() {
                          _newOffers = val;
                          if (!val) _allNotifications = false;
                        });
                        _savePreferences();
                      },
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),
                    _buildSwitchRow(
                      icon: Icons.alarm_rounded,
                      iconColor: const Color(0xFF22C55E),
                      title: 'Ofertas por vencer',
                      subtitle: 'Recibe recordatorios de ofertas flash a punto de terminar.',
                      value: _expiringOffers,
                      isDark: isDark,
                      onChanged: (val) {
                        setState(() {
                          _expiringOffers = val;
                          if (!val) _allNotifications = false;
                        });
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: GENERAL
              _buildSectionHeader('GENERAL', isDark: isDark),
              const SizedBox(height: 8),
              Container(
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
                child: _buildSwitchRow(
                  icon: Icons.campaign_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Mensajes importantes de la app',
                  subtitle: 'Recibe actualizaciones relevantes, novedades y avisos importantes.',
                  value: _importantMessages,
                  isDark: isDark,
                  onChanged: (val) {
                    setState(() {
                      _importantMessages = val;
                      if (!val) _allNotifications = false;
                    });
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Control Notice Green Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tú tienes el control',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Puedes cambiar tus preferencias de notificaciones cuando quieras.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isDark}) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSingleToggleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF16A34A),
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF16A34A),
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
