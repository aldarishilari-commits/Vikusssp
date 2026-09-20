import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/business_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../auth/domain/models/user_profile_model.dart';
import '../../../business/presentation/screens/business_profile_screen.dart';
import '../../../business/presentation/screens/registration/business_registration_flow_screen.dart';
import '../../../home/presentation/widgets/business_card_item.dart';
import 'edit_profile_screen.dart';
import 'management/edit_business_info_bottom_sheet.dart';
import 'management/manage_offers_bottom_sheet.dart';
import 'management/manage_photos_bottom_sheet.dart';
import 'management/manage_products_bottom_sheet.dart';
import 'management/manage_schedule_bottom_sheet.dart';
import 'management/manage_services_bottom_sheet.dart';
import 'management/manage_social_links_bottom_sheet.dart';
import 'pro/vikus_pro_subscription_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String selectedCity;
  final VoidCallback onCityChange;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.selectedCity,
    required this.onCityChange,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Active Profile Tab: 0 = "Mi Perfil" (Personal), 1 = "Mi Negocio" (Administración Pro)
  int _activeProfileTab = 0;

  UserProfileModel? _profile;
  BusinessFullDetails? _myBusinessDetails;
  bool _isLoadingBusiness = false;

  String _userName = 'Aldaris Guzmán';
  String _userPhone = '78946546';
  String _userEmail = 'aldarisguzman@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBusinessDetails();
    BusinessService.instance.businessUpdatesNotifier.addListener(_onBusinessUpdated);
  }

  @override
  void dispose() {
    BusinessService.instance.businessUpdatesNotifier.removeListener(_onBusinessUpdated);
    super.dispose();
  }

  void _onBusinessUpdated() {
    if (mounted) {
      _loadBusinessDetails();
    }
  }

  Future<void> _loadBusinessDetails() async {
    if (!mounted) return;
    setState(() => _isLoadingBusiness = true);
    try {
      final details = await BusinessService.instance.getMyBusiness();
      if (mounted) {
        setState(() {
          _myBusinessDetails = details;
          _isLoadingBusiness = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBusiness = false);
      }
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService().getCurrentProfile();
    if (mounted && profile != null) {
      setState(() {
        _profile = profile;
        _userName = profile.fullName.isNotEmpty ? profile.fullName : _userName;
        _userPhone = profile.phone ?? _userPhone;
        _userEmail = profile.email.isNotEmpty ? profile.email : _userEmail;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().signOut();
    widget.onLogout();
  }

  // Followed Businesses data
  final List<BusinessModel> _followedBusinesses = [
    const BusinessModel(
      id: 'biz_1',
      name: 'BODY XTREME',
      category: 'Deporte',
      description: 'Pesas y máquinas de musculación, entrenadores certificados.',
      address: 'Av. Pando',
      distance: 'a 300 m de ti',
      rating: 4.0,
      reviewsCount: 24,
      isOpen: true,
      closingTime: '19:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
      categoryIcon: Icons.fitness_center_rounded,
      facebook: 'https://facebook.com/bodyxtremelapaz',
      instagram: 'bodyxtreme.bo',
      tiktok: 'bodyxtremelapaz',
      website: 'https://bodyxtreme.com',
    ),
    const BusinessModel(
      id: 'biz_2',
      name: 'BODY XTREME SAN PEDRO',
      category: 'Deporte',
      description: 'Gym con atención cercana, spinning y precios accesibles.',
      address: 'Av. Pando',
      distance: 'a 300 m de ti',
      rating: 4.0,
      reviewsCount: 24,
      isOpen: true,
      closingTime: '19:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
      categoryIcon: Icons.fitness_center_rounded,
      facebook: 'https://facebook.com/bodyxtremesanpedro',
      instagram: 'bodyxtreme.sanpedro',
      tiktok: 'bodyxtreme_bo',
      website: 'https://bodyxtreme.com',
    ),
    const BusinessModel(
      id: 'biz_3',
      name: 'PIZZA CENTER',
      category: 'Comida',
      description: 'Pizzas al horno de piedra, pastas y promociones familiares.',
      address: 'Av. Principal',
      distance: 'a 300 m de ti',
      rating: 4.8,
      reviewsCount: 86,
      isOpen: true,
      closingTime: '23:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg',
      categoryIcon: Icons.local_pizza_rounded,
      facebook: 'https://facebook.com/pizzacenterlapaz',
      instagram: 'pizzacenter.bo',
      tiktok: 'pizzacenterbo',
      website: 'https://pizzacenter.bo',
    ),
  ];

  void _openSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onLogout: _handleLogout,
          onNavigateToBusinessTab: () {
            setState(() => _activeProfileTab = 1);
          },
        ),
      ),
    );
  }

  void _openEditProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialName: _userName,
          initialPhone: _userPhone,
          initialEmail: _userEmail,
          onSaved: (name, phone, email) {
            setState(() {
              _userName = name;
              _userPhone = phone;
              _userEmail = email;
              if (_profile != null) {
                _profile = _profile!.copyWith(
                  fullName: name,
                  phone: phone,
                  email: email,
                );
              }
            });
          },
        ),
      ),
    );
  }

  void _openVikusProScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VikusProSubscriptionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: "Mi perfil" + Purple Hamburger Menu Button
          _buildTopBar(),

          // User Profile Card (Avatar, Name, Location badge ✨, Tagline & Edit button)
          _buildUserProfileCard(),
          const SizedBox(height: 16),

          // Pestañas / Tabs: "Mi Perfil" (Personal) | "Mi Negocio" (Administración Pro)
          _buildTabSelector(),
          const SizedBox(height: 16),

          // Tab Content
          if (_activeProfileTab == 0)
            _buildPersonalProfileTabContent()
          else
            _buildBusinessAdminTabContent(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header & User Identity (matching Mi Perfil (2).png)
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mi perfil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            onPressed: _openSettingsScreen,
            tooltip: 'Configuración',
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 24,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarLetter = _userName.trim().isNotEmpty
        ? _userName.trim()[0].toUpperCase()
        : 'A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Avatar with Camera Badge
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF93C5FD), // Light blue circle from stitch reference
                ),
                child: Center(
                  child: Text(
                    avatarLetter,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // User Info & Edit Profile Pill Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                // Location Pin with sparkles
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFC084FC)),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.selectedCity}, Bolivia',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('✨', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Descubriendo negocios cerca de ti',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 10),

                // Button "Editar perfil"
                GestureDetector(
                  onTap: _openEditProfileScreen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC084FC),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Editar perfil',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Selector: "Mi Perfil" (Personal) | "Mi Negocio" (Administración Pro)
  // ---------------------------------------------------------------------------

  Widget _buildTabSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabPill(
                index: 0,
                title: 'Mi Perfil',
                icon: Icons.person_rounded,
              ),
            ),
            Expanded(
              child: _buildTabPill(
                index: 1,
                title: 'Mi Negocio',
                icon: Icons.storefront_rounded,
                badge: 'PRO',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String title,
    required IconData icon,
    String? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _activeProfileTab == index;

    return GestureDetector(
      onTap: () => setState(() => _activeProfileTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2E2B36) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark ? const Color(0x30000000) : const Color(0x0A000000),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF1B1C1C))
                      : const Color(0xFF6B7280),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A2F),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Personal Profile View (matching screen 1 of Mi Perfil (2).png)
  // ---------------------------------------------------------------------------

  Widget _buildPersonalProfileTabContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: "Negocios que sigues" (Ver todos >)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Negocios que sigues',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mostrando todos los negocios seguidos')),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Ver todos',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List of Followed Business Cards
        SizedBox(
          height: 196,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _followedBusinesses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              return _buildFollowedBusinessCard(_followedBusinesses[i]);
            },
          ),
        ),
        const SizedBox(height: 20),

        // Banner "¿Tienes un negocio?" matching Stitch
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildRegisterBusinessPromoBanner(),
        ),
        const SizedBox(height: 20),

        // Quick Settings Access
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B24) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildQuickSettingRow(
                  icon: Icons.location_city_rounded,
                  title: 'Ciudad Actual',
                  subtitle: widget.selectedCity,
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: widget.onCityChange,
                ),
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
                ),
                _buildQuickSettingRow(
                  icon: Icons.chat_bubble_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Contacto y Soporte WhatsApp',
                  subtitle: 'Atención personalizada Vikus',
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📲 Abriendo soporte por WhatsApp...'),
                        backgroundColor: Color(0xFF22C55E),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowedBusinessCard(BusinessModel business) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BusinessProfileScreen(business: business),
          ),
        );
      },
      child: Container(
        width: 154,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B24) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x08000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with top-right heart icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  child: Image.network(
                    business.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 100,
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, color: Color(0xFF9CA3AF), size: 30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFFEF4444)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          business.distance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Abierto ahora',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterBusinessPromoBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF271B3B) : const Color(0xFFF3E8FF), // Soft violet background
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFE9D5FF),
        ),
      ),
      child: Row(
        children: [
          // Storefront icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B24) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.storefront_rounded,
                size: 28,
                color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Texts and CTA Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Tienes un negocio?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Regístralo gratis y llega a más clientes cerca de ti.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BusinessRegistrationFlowScreen(
                          onCompleted: () {
                            setState(() => _activeProfileTab = 1);
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Registrar negocio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Business Administration View (matching screens 2 & 3 of Mi Perfil (2).png)
  // ---------------------------------------------------------------------------

  Widget _buildBusinessAdminTabContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingBusiness && _myBusinessDetails == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                'Cargando datos de tu negocio...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Summary Header Card
          _buildBusinessHeaderCard(),
          const SizedBox(height: 16),

          // Boost Banner ("Impulsar negocio")
          _buildBoostBusinessBanner(),
          const SizedBox(height: 18),

          // Performance Metrics ("Tu rendimiento")
          Text(
            'Tu rendimiento',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(height: 10),
          _buildPerformanceMetricsRow(),
          const SizedBox(height: 20),

          // Quick Actions ("Acciones rápidas")
          Text(
            'Acciones rápidas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickActionsRow(),
          const SizedBox(height: 20),

          // Administration Modules List ("Administrar negocio")
          Text(
            'Administrar negocio',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(height: 10),
          _buildAdminModulesList(),
          const SizedBox(height: 18),

          // Create New Business Button
          _buildCreateNewBusinessButton(),
        ],
      ),
    );
  }

  Widget _buildBusinessHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final biz = _myBusinessDetails?.business;
    final name = biz?.name ?? "Elis' Pizza";
    final address = biz?.address.isNotEmpty == true ? biz!.address : 'Av. Montes, ${widget.selectedCity}';
    final imageUrl = biz?.imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: 64,
                height: 64,
                color: isDark ? const Color(0xFF271B3B) : const Color(0xFFF3E8FF),
                child: const Center(
                  child: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Activa',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFFEF4444)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (biz != null) {
                          EditBusinessInfoBottomSheet.show(
                            context,
                            business: biz,
                            onUpdated: _loadBusinessDetails,
                          );
                        } else {
                          AppNotification.showInfo(context, 'Registra un negocio primero para editar sus datos');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 15,
                            color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Editar info',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (biz != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BusinessProfileScreen(business: biz),
                            ),
                          );
                        } else {
                          AppNotification.showInfo(context, 'Registra un negocio primero para ver su perfil');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ver perfil',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostBusinessBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openVikusProScreen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF271B3B) : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF3F2B5C) : const Color(0xFFDDD6FE),
            ),
          ),
          child: Row(
            children: [
              // Rocket circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impulsar negocio',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                    Text(
                      'Aparece primero y consigue más clientes',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _openVikusProScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Activar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetricsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offersCount = _myBusinessDetails?.flashOffers.length ?? 0;
    final rating = _myBusinessDetails?.business.rating.toStringAsFixed(1) ?? '4.5';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(icon: Icons.visibility_rounded, value: '1.142', label: 'Vistas', color: const Color(0xFF6366F1)),
          Container(
            width: 1,
            height: 28,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildMetricItem(icon: Icons.favorite_rounded, value: '322', label: 'Favoritos', color: const Color(0xFFEF4444)),
          Container(
            width: 1,
            height: 28,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildMetricItem(icon: Icons.local_fire_department_rounded, value: '$offersCount', label: 'Ofertas act.', color: const Color(0xFFF97316)),
          Container(
            width: 1,
            height: 28,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildMetricItem(icon: Icons.star_rounded, value: rating, label: 'Calificación', color: const Color(0xFFEAB308)),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow() {
    final biz = _myBusinessDetails?.business;
    final businessId = biz?.id ?? '';
    final businessName = biz?.name ?? 'Mi Negocio';

    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.local_offer_rounded,
            label: 'Crear oferta\nespecial',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageOffersBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialOffers: _myBusinessDetails?.flashOffers ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.inventory_2_rounded,
            label: 'Agregar\nproducto',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageProductsBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialProducts: _myBusinessDetails?.products ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.room_service_rounded,
            label: 'Agregar\nservicio',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageServicesBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialServices: _myBusinessDetails?.services ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B24) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x06000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E1B4E) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminModulesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final biz = _myBusinessDetails?.business;
    final businessId = biz?.id ?? '';
    final businessName = biz?.name ?? 'Mi Negocio';

    final offersCount = _myBusinessDetails?.flashOffers.length ?? 0;
    final productsCount = _myBusinessDetails?.products.length ?? 0;
    final servicesCount = _myBusinessDetails?.services.length ?? 0;
    final photosCount = _myBusinessDetails?.photos.length ?? (biz?.photoUrls.length ?? 0);

    final scheduleSummary = _formatScheduleSummary(biz?.schedules);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAdminRow(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFF97316),
            title: 'Ofertas activas',
            counterBadge: '$offersCount',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageOffersBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialOffers: _myBusinessDetails?.flashOffers ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildAdminRow(
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'Productos',
            counterBadge: '$productsCount',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageProductsBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialProducts: _myBusinessDetails?.products ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildAdminRow(
            icon: Icons.room_service_rounded,
            iconColor: const Color(0xFFEAB308),
            title: 'Servicios',
            counterBadge: '$servicesCount',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageServicesBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialServices: _myBusinessDetails?.services ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildAdminRow(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Fotos del negocio',
            counterBadge: '$photosCount',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManagePhotosBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialPhotos: _myBusinessDetails?.photos ?? [],
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildAdminRow(
            icon: Icons.access_time_filled_rounded,
            iconColor: const Color(0xFF22C55E),
            title: 'Horario',
            infoText: scheduleSummary,
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageScheduleBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialSchedules: biz?.schedules,
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6),
          ),
          _buildAdminRow(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF6366F1),
            title: 'Redes sociales y página web',
            onTap: () {
              if (businessId.isEmpty) {
                AppNotification.showInfo(context, 'Primero registra un negocio');
                return;
              }
              ManageSocialLinksBottomSheet.show(
                context,
                businessId: businessId,
                businessName: businessName,
                initialPhone: biz?.phoneNumber,
                initialWhatsapp: biz?.phoneNumber,
                initialFacebook: biz?.facebook,
                initialInstagram: biz?.instagram,
                initialTiktok: biz?.tiktok,
                initialWebsite: biz?.website,
                onUpdated: _loadBusinessDetails,
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatScheduleSummary(Map<String, dynamic>? schedules) {
    if (schedules == null || schedules.isEmpty) {
      return 'Lun - Dom: 08:00 - 20:00';
    }
    return 'Lun - Dom configurado';
  }

  Widget _buildAdminRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? counterBadge,
    String? infoText,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
            ),
            if (infoText != null) ...[
              Text(
                infoText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (counterBadge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E1B4E) : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  counterBadge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewBusinessButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BusinessRegistrationFlowScreen(
              onCompleted: () {
                setState(() => _activeProfileTab = 1);
              },
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B24) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFC084FC),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 22,
              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
            ),
            const SizedBox(width: 8),
            Text(
              'Crear nuevo negocio',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? (isDark ? const Color(0xFFC084FC) : AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? (isDark ? Colors.white : const Color(0xFF1B1C1C)),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

