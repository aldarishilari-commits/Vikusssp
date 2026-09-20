import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/business_service.dart';

class ManageSocialLinksBottomSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String? initialPhone;
  final String? initialWhatsapp;
  final String? initialFacebook;
  final String? initialInstagram;
  final String? initialTiktok;
  final String? initialWebsite;
  final VoidCallback onUpdated;

  const ManageSocialLinksBottomSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    this.initialPhone,
    this.initialWhatsapp,
    this.initialFacebook,
    this.initialInstagram,
    this.initialTiktok,
    this.initialWebsite,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String businessId,
    required String businessName,
    String? initialPhone,
    String? initialWhatsapp,
    String? initialFacebook,
    String? initialInstagram,
    String? initialTiktok,
    String? initialWebsite,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageSocialLinksBottomSheet(
        businessId: businessId,
        businessName: businessName,
        initialPhone: initialPhone,
        initialWhatsapp: initialWhatsapp,
        initialFacebook: initialFacebook,
        initialInstagram: initialInstagram,
        initialTiktok: initialTiktok,
        initialWebsite: initialWebsite,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageSocialLinksBottomSheet> createState() => _ManageSocialLinksBottomSheetState();
}

class _ManageSocialLinksBottomSheetState extends State<ManageSocialLinksBottomSheet> {
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _websiteController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _whatsappController = TextEditingController(text: widget.initialWhatsapp ?? widget.initialPhone ?? '');
    _facebookController = TextEditingController(text: widget.initialFacebook ?? '');
    _instagramController = TextEditingController(text: widget.initialInstagram ?? '');
    _tiktokController = TextEditingController(text: widget.initialTiktok ?? '');
    _websiteController = TextEditingController(text: widget.initialWebsite ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveLinks() async {
    setState(() => _isSaving = true);
    try {
      await BusinessService.instance.updateBusinessSocialLinks(
        widget.businessId,
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        facebook: _facebookController.text.trim(),
        instagram: _instagramController.text.trim(),
        tiktok: _tiktokController.text.trim(),
        website: _websiteController.text.trim(),
      );

      if (!mounted) return;
      widget.onUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Redes sociales y contacto actualizados con éxito',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12141C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.share_rounded, color: Color(0xFF06B6D4), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redes Sociales y Web',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Conecta a tus clientes directamente con tu negocio',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _buildFieldCard(
                  title: 'WhatsApp Business / Directo',
                  hint: 'Ej: 59171234567',
                  helper: 'Permite a los clientes enviarte mensajes con un solo toque',
                  controller: _whatsappController,
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF25D366),
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  title: 'Teléfono de Contacto / Llamadas',
                  hint: 'Ej: 71234567 o 38421000',
                  helper: 'Número para recibir llamadas de clientes',
                  controller: _phoneController,
                  icon: Icons.phone_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  title: 'Página Web / Tienda Online',
                  hint: 'Ej: https://mitienda.com',
                  helper: 'Tu sitio web oficial o catálogo externo',
                  controller: _websiteController,
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF6366F1),
                  keyboardType: TextInputType.url,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  title: 'Facebook',
                  hint: 'Ej: https://facebook.com/minegocio',
                  helper: 'Enlace a tu página o perfil de Facebook',
                  controller: _facebookController,
                  icon: Icons.facebook_rounded,
                  iconColor: const Color(0xFF1877F2),
                  keyboardType: TextInputType.url,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  title: 'Instagram',
                  hint: 'Ej: @minegocio o https://instagram.com/minegocio',
                  helper: 'Perfil de Instagram para mostrar tus productos',
                  controller: _instagramController,
                  icon: Icons.camera_alt_rounded,
                  iconColor: const Color(0xFFE1306C),
                  keyboardType: TextInputType.text,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  title: 'TikTok',
                  hint: 'Ej: @minegocio o https://tiktok.com/@minegocio',
                  helper: 'Tu cuenta de videos cortos y promociones',
                  controller: _tiktokController,
                  icon: Icons.music_note_rounded,
                  iconColor: const Color(0xFF00F2FE),
                  keyboardType: TextInputType.text,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161822) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveLinks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                label: Text(
                  _isSaving ? 'Guardando...' : 'Guardar Redes Sociales',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard({
    required String title,
    required String hint,
    required String helper,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required TextInputType keyboardType,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white30 : Colors.grey[400],
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF12141C) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: iconColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
