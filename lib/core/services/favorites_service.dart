import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/home/presentation/widgets/business_card_item.dart';
import '../../features/offers/data/models/offer_model.dart';

/// Modelo para los productos del catálogo guardados en favoritos
class BusinessProductItem {
  final String id;
  final String title;
  final String price;
  final String originalPrice;
  final String discount;
  final String timer;
  final String stock;
  final String imageUrl;
  final String businessName;

  const BusinessProductItem({
    required this.id,
    required this.title,
    required this.price,
    this.originalPrice = '',
    this.discount = '',
    this.timer = '',
    this.stock = '',
    required this.imageUrl,
    this.businessName = '',
  });
}

/// Modelo para los servicios que ofrece el negocio guardados en favoritos
class BusinessServiceItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final double numericPrice;
  final String imageUrl;
  final String businessName;

  const BusinessServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.numericPrice,
    required this.imageUrl,
    this.businessName = '',
  });
}

/// Servicio singleton centralizado para gestionar favoritos de Negocios, Servicios, Productos y Ofertas
class FavoritesService extends ChangeNotifier {
  FavoritesService._() {
    _initInitialData();
  }

  static final FavoritesService instance = FavoritesService._();

  final List<BusinessModel> _favoriteBusinesses = [];
  final List<BusinessServiceItem> _favoriteServices = [];
  final List<BusinessProductItem> _favoriteProducts = [];
  final List<OfferModel> _favoriteOffers = [];

  List<BusinessModel> get favoriteBusinesses => List.unmodifiable(_favoriteBusinesses);
  List<BusinessServiceItem> get favoriteServices => List.unmodifiable(_favoriteServices);
  List<BusinessProductItem> get favoriteProducts => List.unmodifiable(_favoriteProducts);
  List<OfferModel> get favoriteOffers => List.unmodifiable(_favoriteOffers);

  int get totalFavoritesCount =>
      _favoriteBusinesses.length +
      _favoriteServices.length +
      _favoriteProducts.length +
      _favoriteOffers.length;

  void _initInitialData() {
    // Negocios iniciales de ejemplo
    _favoriteBusinesses.addAll([
      const BusinessModel(
        id: 'biz_1',
        name: 'BODY XTREME',
        category: 'Deporte',
        description: 'Pesas y máquinas de musculación, entrenadores certificados.',
        address: 'Av. Pando',
        distance: '300 m de ti',
        rating: 4.0,
        reviewsCount: 24,
        isOpen: true,
        closingTime: '19:00',
        promoBadge: 'OFERTA',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        categoryIcon: Icons.fitness_center_rounded,
        isFavorite: true,
        facebook: 'https://facebook.com/bodyxtremelapaz',
        instagram: 'bodyxtreme.bo',
        tiktok: 'bodyxtremelapaz',
        website: 'https://bodyxtreme.com',
      ),
      const BusinessModel(
        id: 'biz_3',
        name: 'PIZZA CENTER',
        category: 'Comida',
        description: 'Pizzas al horno de piedra, pastas y promociones familiares.',
        address: 'Av. Principal',
        distance: '300 m de ti',
        rating: 4.8,
        reviewsCount: 86,
        isOpen: true,
        closingTime: '23:00',
        promoBadge: '2X1 HOY',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg',
        categoryIcon: Icons.local_pizza_rounded,
        isFavorite: true,
        facebook: 'https://facebook.com/pizzacenterlapaz',
        instagram: 'pizzacenter.bo',
        tiktok: 'pizzacenterbo',
        website: 'https://pizzacenter.bo',
      ),
    ]);

    // Servicios iniciales de ejemplo
    _favoriteServices.addAll([
      const BusinessServiceItem(
        id: 'serv_dent_1',
        title: 'Limpieza dental',
        description: 'Elimina la placa y sarro para mejor salud bucal.',
        price: 'Bs. 65',
        numericPrice: 65.0,
        imageUrl:
            'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=500&auto=format&fit=crop&q=60',
        businessName: 'Dental Care Center',
      ),
      const BusinessServiceItem(
        id: 'serv_fit_1',
        title: 'Entrenamiento Personalizado',
        description: 'Rutina adaptada a tus metas y seguimiento 1 a 1 por coach certificado.',
        price: 'Bs. 350',
        numericPrice: 350.0,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        businessName: 'BODY XTREME',
      ),
    ]);

    // Productos iniciales de ejemplo
    _favoriteProducts.addAll([
      const BusinessProductItem(
        id: 'prod_1',
        title: 'Pan de Molde Especial',
        price: 'Bs. 65',
        originalPrice: 'Bs 50',
        discount: '-15%',
        timer: '2:00',
        stock: 'Quedan 2',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCujNPFmhhL2pwel9ID-P0QFK_mKLWl02IXlUiLG59xcjf-RLs1u7tc9JwqwRN3UqabWDsX_b99SKYifo4peqXJryozIPufjUVsjisnmloNFeIdg0XsXUZ4zyuoS-XcofaKijJt6vl69NciiN6pfamMudLJTrPh2X3ynHnhTaraQ7bz-q5ZFXq7LvId2yt7SBUMUxrfYDciJOn5aBo4PjtI7M1iHvh_2_JUxyGpoYMexlhbEvmi3vQ-ww',
        businessName: 'Panadería Central',
      ),
    ]);

    // Ofertas iniciales de ejemplo
    final initialOffers = OfferModel.getInitialOffers();
    if (initialOffers.isNotEmpty) {
      _favoriteOffers.add(initialOffers.first.copyWith(isFavorite: true));
    }
  }

  // --- Negocios ---
  bool isBusinessFavorite(String id) {
    return _favoriteBusinesses.any((b) => b.id == id);
  }

  bool toggleBusinessFavorite(BusinessModel business, [BuildContext? context]) {
    final exists = isBusinessFavorite(business.id);
    if (exists) {
      _favoriteBusinesses.removeWhere((b) => b.id == business.id);
    } else {
      _favoriteBusinesses.add(business.copyWith(isFavorite: true));
    }
    notifyListeners();
    return !exists;
  }

  // --- Servicios ---
  bool isServiceFavorite(String id) {
    return _favoriteServices.any((s) => s.id == id);
  }

  bool toggleServiceFavorite(BusinessServiceItem service, [BuildContext? context]) {
    final exists = isServiceFavorite(service.id);
    if (exists) {
      _favoriteServices.removeWhere((s) => s.id == service.id);
    } else {
      _favoriteServices.add(service);
    }
    notifyListeners();
    return !exists;
  }

  // --- Productos ---
  bool isProductFavorite(String id) {
    return _favoriteProducts.any((p) => p.id == id);
  }

  bool toggleProductFavorite(BusinessProductItem product, [BuildContext? context]) {
    final exists = isProductFavorite(product.id);
    if (exists) {
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
    return !exists;
  }

  // --- Ofertas ---
  bool isOfferFavorite(String id) {
    return _favoriteOffers.any((o) => o.id == id);
  }

  bool toggleOfferFavorite(OfferModel offer, [BuildContext? context]) {
    final exists = isOfferFavorite(offer.id);
    if (exists) {
      _favoriteOffers.removeWhere((o) => o.id == offer.id);
    } else {
      _favoriteOffers.add(offer.copyWith(isFavorite: true));
    }
    notifyListeners();
    return !exists;
  }

  /// Muestra el Toast flotante morado con la imagen miniatura del elemento y el mensaje
  /// con el diseño idéntico a la referencia del usuario
  static void showFavoriteToast(
    BuildContext context, {
    required String categoryName,
    required String imageUrl,
    required IconData fallbackIcon,
    required bool isAdded,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.zero,
        duration: const Duration(milliseconds: 2200),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B1FF5), // Brand purple matching user screenshot
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B1FF5).withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image Thumbnail with rounded rectangle corners
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.2),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: Icon(fallbackIcon, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Notification text
              Expanded(
                child: Text(
                  isAdded
                      ? 'Guardado en $categoryName favoritos'
                      : 'Eliminado de $categoryName favoritos',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
