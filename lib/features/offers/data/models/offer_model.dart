import 'package:flutter/material.dart';

enum OfferSectionType {
  expiringSoon,
  followingBusinesses,
  allOffers,
}

class OfferModel {
  final String id;
  final String title;
  final String businessName;
  final String businessCategory;
  final IconData categoryIcon;
  final double originalPrice;
  final double discountedPrice;
  final String discountBadge;
  final String timeRemaining;
  final String distance;
  final String imageUrl;
  final bool isFavorite;
  final OfferSectionType sectionType;
  final String phoneNumber;
  final String stockRemaining;
  final String validUntil;
  final String offerType;

  const OfferModel({
    required this.id,
    required this.title,
    required this.businessName,
    required this.businessCategory,
    required this.categoryIcon,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountBadge,
    required this.timeRemaining,
    required this.distance,
    required this.imageUrl,
    this.isFavorite = false,
    required this.sectionType,
    this.phoneNumber = '70123456',
    this.stockRemaining = '10 disponibles',
    this.validUntil = 'Válido hoy hasta medianoche',
    this.offerType = 'Descuento',
  });

  OfferModel copyWith({
    String? id,
    String? title,
    String? businessName,
    String? businessCategory,
    IconData? categoryIcon,
    double? originalPrice,
    double? discountedPrice,
    String? discountBadge,
    String? timeRemaining,
    String? distance,
    String? imageUrl,
    bool? isFavorite,
    OfferSectionType? sectionType,
    String? phoneNumber,
    String? stockRemaining,
    String? validUntil,
    String? offerType,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountBadge: discountBadge ?? this.discountBadge,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      sectionType: sectionType ?? this.sectionType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      stockRemaining: stockRemaining ?? this.stockRemaining,
      validUntil: validUntil ?? this.validUntil,
      offerType: offerType ?? this.offerType,
    );
  }

  /// Initial sample dataset matching the exact cards shown in the user's reference screenshot
  static List<OfferModel> getInitialOffers() {
    return [
      // -------------------------------------------------------------
      // 1. SECCIÓN: Terminan pronto (Expiring Soon)
      // -------------------------------------------------------------
      const OfferModel(
        id: 'offer_1',
        title: 'Hamburguesa clásica + papas',
        businessName: 'La Burguesa',
        businessCategory: 'Hamburguesería & Grill',
        categoryIcon: Icons.restaurant_rounded,
        originalPrice: 50.0,
        discountedPrice: 40.0,
        discountBadge: '-20%',
        timeRemaining: '2 h 18 min',
        distance: '800 m',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.expiringSoon,
        phoneNumber: '78946512',
        stockRemaining: '6 combos restantes',
        validUntil: 'Válido hoy hasta las 23:00',
        offerType: 'Combo',
      ),
      const OfferModel(
        id: 'offer_2',
        title: 'Zapatillas deportivas',
        businessName: 'Urban Sport',
        businessCategory: 'Calzado & Moda Deportiva',
        categoryIcon: Icons.directions_run_rounded,
        originalPrice: 450.0,
        discountedPrice: 315.0,
        discountBadge: '-30%',
        timeRemaining: '5 h 42 min',
        distance: '1.2 km',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.expiringSoon,
        phoneNumber: '71239845',
        stockRemaining: '3 pares disponibles',
        validUntil: 'Válido hasta agotar stock',
        offerType: 'Descuento',
      ),
      const OfferModel(
        id: 'offer_3',
        title: 'Café grande + brownie',
        businessName: 'Café del Cerro',
        businessCategory: 'Cafetería & Pastelería',
        categoryIcon: Icons.local_cafe_rounded,
        originalPrice: 28.0,
        discountedPrice: 21.0,
        discountBadge: '-25%',
        timeRemaining: '3 h 10 min',
        distance: '1.4 km',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.expiringSoon,
        phoneNumber: '77889900',
        stockRemaining: '12 porciones',
        validUntil: 'Válido hoy hasta las 20:00',
        offerType: 'Combo',
      ),

      // -------------------------------------------------------------
      // 2. SECCIÓN: De los negocios que sigues (Following Businesses)
      // -------------------------------------------------------------
      const OfferModel(
        id: 'offer_4',
        title: 'Membresía mensual',
        businessName: 'FitLife Gym',
        businessCategory: 'Gimnasio & Fitness',
        categoryIcon: Icons.fitness_center_rounded,
        originalPrice: 120.0,
        discountedPrice: 96.0,
        discountBadge: '-20%',
        timeRemaining: '4 h 15 min',
        distance: '300 m',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.followingBusinesses,
        phoneNumber: '76543210',
        stockRemaining: '5 cupos promocionales',
        validUntil: 'Válido para nuevos miembros',
        offerType: 'Descuento',
      ),
      const OfferModel(
        id: 'offer_5',
        title: 'Café + croissant',
        businessName: 'Cafetería del Cerro',
        businessCategory: 'Cafetería & Panadería',
        categoryIcon: Icons.local_cafe_rounded,
        originalPrice: 32.0,
        discountedPrice: 27.0,
        discountBadge: '-15%',
        timeRemaining: '6 h 30 min',
        distance: '1.4 km',
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.followingBusinesses,
        phoneNumber: '77889900',
        stockRemaining: '8 combos disponibles',
        validUntil: 'Válido para desayunos y meriendas',
        offerType: 'Combo',
      ),
      const OfferModel(
        id: 'offer_6',
        title: 'Buzo deportivo',
        businessName: 'Sport Zone',
        businessCategory: 'Ropa Deportiva & Casual',
        categoryIcon: Icons.checkroom_rounded,
        originalPrice: 80.0,
        discountedPrice: 60.0,
        discountBadge: '-25%',
        timeRemaining: '8 h 25 min',
        distance: '1.5 km',
        imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.followingBusinesses,
        phoneNumber: '70011223',
        stockRemaining: '4 unidades en talla M/L',
        validUntil: 'Válido toda la semana',
        offerType: 'Descuento',
      ),

      // -------------------------------------------------------------
      // 3. SECCIÓN: Todas las ofertas (All Offers)
      // -------------------------------------------------------------
      const OfferModel(
        id: 'offer_7',
        title: 'Pizza familiar',
        businessName: 'Pizzería El Buen Sabor',
        businessCategory: 'Pizzería Artesanal',
        categoryIcon: Icons.local_pizza_rounded,
        originalPrice: 90.0,
        discountedPrice: 63.0,
        discountBadge: '-30%',
        timeRemaining: '1 h 20 min',
        distance: '900 m',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.allOffers,
        phoneNumber: '75566778',
        stockRemaining: '10 pizzas disponibles',
        validUntil: 'Válido para consumo en local y delivery',
        offerType: '2x1',
      ),
      const OfferModel(
        id: 'offer_8',
        title: 'Masaje relajante',
        businessName: 'Spa Relax',
        businessCategory: 'Spa & Cuidado Personal',
        categoryIcon: Icons.spa_rounded,
        originalPrice: 150.0,
        discountedPrice: 120.0,
        discountBadge: '-20%',
        timeRemaining: '12 h 45 min',
        distance: '2.3 km',
        imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.allOffers,
        phoneNumber: '74455667',
        stockRemaining: '3 citas disponibles hoy',
        validUntil: 'Válido con reserva previa',
        offerType: 'Descuento',
      ),
      const OfferModel(
        id: 'offer_9',
        title: 'Ropa casual',
        businessName: 'Moda Urbana',
        businessCategory: 'Boutique & Moda',
        categoryIcon: Icons.checkroom_rounded,
        originalPrice: 70.0,
        discountedPrice: 42.0,
        discountBadge: '-40%',
        timeRemaining: '2 d 6 h',
        distance: '1.7 km',
        imageUrl: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&auto=format&fit=crop&q=80',
        sectionType: OfferSectionType.allOffers,
        phoneNumber: '73344556',
        stockRemaining: 'Colección de temporada',
        validUntil: 'Válido hasta agotar stock',
        offerType: 'Descuento',
      ),
    ];
  }
}
