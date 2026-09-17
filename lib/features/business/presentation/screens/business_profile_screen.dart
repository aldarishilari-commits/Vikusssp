import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/map_launcher_service.dart';
import '../../../../core/services/social_launcher_service.dart';
import '../../../../core/services/whatsapp_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../../home/presentation/widgets/business_card_item.dart';
import '../../../offers/data/models/offer_model.dart';
import '../../../offers/presentation/widgets/offer_detail_bottom_sheet.dart';
import '../widgets/business_schedule_bottom_sheet.dart';



/// Modelo para las tarjetas horizontales de ofertas destacadas
class BusinessSpecialOfferItem {
  final String id;
  final String badge;
  final String discountHeadline;
  final String title;
  final String timerBadge;
  final String imageUrl;
  final String originalPrice;
  final String offerPrice;

  const BusinessSpecialOfferItem({
    required this.id,
    this.badge = 'Nuevo',
    required this.discountHeadline,
    required this.title,
    this.timerBadge = 'Solo hoy',
    required this.imageUrl,
    this.originalPrice = '',
    this.offerPrice = '',
  });
}

class BusinessProfileScreen extends StatefulWidget {
  final BusinessModel business;
  final ValueChanged<bool>? onFavoriteToggle;

  const BusinessProfileScreen({
    super.key,
    required this.business,
    this.onFavoriteToggle,
  });

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  late bool _isFavorite;
  bool _isFollowing = false;
  int _selectedCatalogTab = 2; // 0: Ofertas flash, 1: Productos, 2: Servicios
  final Set<String> _selectedServiceIds = {};
  late final PageController _coverPageController;
  int _currentCoverIndex = 0;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.instance.isBusinessFavorite(widget.business.id) || widget.business.isFavorite;
    _coverPageController = PageController();
  }

  @override
  void dispose() {
    _coverPageController.dispose();
    super.dispose();
  }

  void _toggleBusinessFavorite() {
    final newFav = FavoritesService.instance.toggleBusinessFavorite(widget.business, context);
    setState(() {
      _isFavorite = newFav;
    });
    widget.onFavoriteToggle?.call(newFav);
  }

  void _toggleProductFavorite(BusinessProductItem prod) {
    FavoritesService.instance.toggleProductFavorite(prod, context);
    setState(() {});
  }

  void _toggleOfferFavorite(BusinessSpecialOfferItem offer) {
    final offerModel = OfferModel(
      id: offer.id,
      title: offer.title,
      businessName: widget.business.name,
      businessCategory: widget.business.category,
      categoryIcon: widget.business.categoryIcon,
      originalPrice: double.tryParse(offer.originalPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 100.0,
      discountedPrice: double.tryParse(offer.offerPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70.0,
      discountBadge: offer.discountHeadline,
      timeRemaining: offer.timerBadge,
      distance: widget.business.distance,
      imageUrl: offer.imageUrl,
      sectionType: OfferSectionType.allOffers,
    );
    FavoritesService.instance.toggleOfferFavorite(offerModel, context);
    setState(() {});
  }

  void _toggleServiceFavorite(BusinessServiceItem service) {
    FavoritesService.instance.toggleServiceFavorite(service, context);
    setState(() {});
  }

  void _toggleServiceSelection(String id) {
    setState(() {
      if (_selectedServiceIds.contains(id)) {
        _selectedServiceIds.remove(id);
      } else {
        _selectedServiceIds.add(id);
      }
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? 'Ahora sigues a ${widget.business.name} 🎉'
              : 'Dejaste de seguir a ${widget.business.name}',
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  /// Construye y envía consulta por WhatsApp con todos los servicios seleccionados
  void _consultSelectedServicesViaWhatsApp(
    BusinessModel b,
    List<BusinessServiceItem> allServices,
  ) {
    final selected = allServices
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();

    if (selected.isEmpty) return;

    final total = selected.fold<double>(
      0.0,
      (sum, item) => sum + item.numericPrice,
    );

    final totalFormatted = total.truncateToDouble() == total
        ? total.toInt().toString()
        : total.toStringAsFixed(2);

    final buffer = StringBuffer();
    buffer.writeln('¡Hola *${b.name}*! 👋');
    buffer.writeln('Quisiera consultar sobre los siguientes servicios que seleccioné en Vikus:');
    buffer.writeln();
    for (final s in selected) {
      buffer.writeln('• *${s.title}* (${s.price})');
    }
    buffer.writeln();
    buffer.writeln('💰 *Total estimado:* Bs. $totalFormatted');
    buffer.writeln();
    buffer.writeln('¿Tienen disponibilidad de atención o citas disponibles? ¡Muchas gracias!');

    WhatsAppLauncherService.openWhatsApp(
      context: context,
      phoneNumber: b.phoneNumber,
      businessName: b.name,
      customMessage: buffer.toString().trim(),
    );
  }

  /// Lista de servicios ofrecidos adaptada según la categoría y perfil del negocio
  List<BusinessServiceItem> _getBusinessServices() {
    final b = widget.business;
    final cat = b.category.toLowerCase();
    final name = b.name.toLowerCase();

    if (cat.contains('salud') ||
        name.contains('dentista') ||
        name.contains('dental') ||
        name.contains('médic')) {
      return const [
        BusinessServiceItem(
          id: 'serv_dent_1',
          title: 'Limpieza dental',
          description: 'Elimina la placa y sarro para mejor salud bocal.',
          price: 'Bs. 65',
          numericPrice: 65.0,
          imageUrl:
              'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_dent_2',
          title: 'Blanqueamiento dental',
          description: 'Tratamiento estético profesional para recuperar el brillo natural.',
          price: 'Bs. 220',
          numericPrice: 220.0,
          imageUrl:
              'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_dent_3',
          title: 'Curaciones dentales',
          description: 'Restauración con resina de alta estética y durabilidad.',
          price: 'Bs. 110',
          numericPrice: 110.0,
          imageUrl:
              'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_dent_4',
          title: 'Evaluación de Ortodoncia',
          description: 'Diagnóstico integral y cotización de brackets o alineadores.',
          price: 'Bs. 80',
          numericPrice: 80.0,
          imageUrl:
              'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_dent_5',
          title: 'Profilaxis y Flúor Infantil',
          description: 'Atención dental suave y preventiva para niños y adolescentes.',
          price: 'Bs. 60',
          numericPrice: 60.0,
          imageUrl:
              'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=500&auto=format&fit=crop&q=60',
        ),
      ];
    } else if (cat.contains('comida') || name.contains('panadería') || name.contains('restaurante')) {
      return const [
        BusinessServiceItem(
          id: 'serv_food_1',
          title: 'Catering para Eventos',
          description: 'Bocaditos dulces y salados frescos para eventos y reuniones.',
          price: 'Bs. 180',
          numericPrice: 180.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDa_GjJLeIkJpaN8Aq5F5gwAFE80r0L6l-4e3R0v2b4uMTgNAQYafhjr4kCyoH9ITj3n377qDs7FMrhg9TVYivy691f9XwS15nObZYssq5R8JomhyCK-Mo4wLPqFthSOdrBWQMc4_7djZn-pABc8MsYzk93dReSeLambeqJl7Y31VlJegBLi7AXEbzdhpmBJT3Dif5aSSXLw9QxSOFNYuNkIGNOqasEWTVW_f4EqrZSJMskF8s_aC3m3g',
        ),
        BusinessServiceItem(
          id: 'serv_food_2',
          title: 'Tortas Personalizadas',
          description: 'Diseño exclusivo con temática a elección y masa artesanal.',
          price: 'Bs. 140',
          numericPrice: 140.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCaK7qX9esbBF3k-YBViYb_YW_faBxTxymDHrJ24RCEXzr3WLMDUnVng9ImkYbsXDuCdPrgplYUxbSAW069NLeDAPClRrQALICvtyHTPz9CRWhVFkvLP_4etWjyNsZrd2JK5nB_l9Jq76FiMBr6M2QL8X2l3AsQYnrdgQWJ63okpNIZoAwAZ7OcnWGH0kaNDZyBYNsNQMJU5a9vahexMcYAXCnUR5JsnzEruGYbSk8N7HIdGKy41CHVHw',
        ),
        BusinessServiceItem(
          id: 'serv_food_3',
          title: 'Mesa de Dulces Gourmet',
          description: 'Variedad de mini postres, tartas y bocadillos para 20 personas.',
          price: 'Bs. 250',
          numericPrice: 250.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDYAyuQG0G0SPNOFBIKINQmfAop2-uaecRghpEdOt03PMPJ4fBu6nG4B4EOxH0OuWi9fM8W8uBiiRp-95yRXt9HuPZnCG6x1lO6-NMcgxUai2d-I8aU0TExx1COYM5XHQWo2NIL8yTKXSGFLgE0IdWZ8A0UWi8Q4WK_NlGqX-QBgDzBXWBa7-wxeOS6deAV9T7ojS-jqqSd8GbDUaZCFS2X5-05BRPZINVrCpq2coKiVG8rjxdu0oTztg',
        ),
        BusinessServiceItem(
          id: 'serv_food_4',
          title: 'Desayunos Sorpresa',
          description: 'Box especial con panes selectos, jugo natural, frutas y dedicatoria.',
          price: 'Bs. 95',
          numericPrice: 95.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA2hDU--JiWYBxdiotcwomQH2NkKz8K82Phos88gVa1mv4Eic-S0lMqcVj_6KjLvQXBMBu-idM2HLtN1M50Zs7DQXqTwws6bMaMa7pligXUQxG8ElJ0twZCINeU7pIr52bklJrBxbqEgs7L3aaRIMcjq86xafLyO8QzE2zfKnnKgFUXbQQ8gkH3eLEFBJZMcEgZbI0z1nJ1bboQ9_u8tp8kncN_gl_elsIm-rBRlIOf6r5rvhhE8SIvGQ',
        ),
      ];
    } else if (cat.contains('fitness') || cat.contains('deporte') || name.contains('gym')) {
      return const [
        BusinessServiceItem(
          id: 'serv_fit_1',
          title: 'Entrenamiento Personalizado',
          description: 'Rutina adaptada a tus metas y seguimiento 1 a 1 por coach certificado.',
          price: 'Bs. 350',
          numericPrice: 350.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        ),
        BusinessServiceItem(
          id: 'serv_fit_2',
          title: 'Evaluación Antropométrica',
          description: 'Medición de porcentaje graso, masa muscular y reporte metabólico.',
          price: 'Bs. 80',
          numericPrice: 80.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
        ),
        BusinessServiceItem(
          id: 'serv_fit_3',
          title: 'Plan Nutricional Deportivo',
          description: 'Pauta alimenticia ajustada a ganancia muscular o quema de grasa.',
          price: 'Bs. 150',
          numericPrice: 150.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        ),
        BusinessServiceItem(
          id: 'serv_fit_4',
          title: 'Pase 10 Clases Spinning / Cross',
          description: 'Acceso a 10 sesiones de alta intensidad con entrenador.',
          price: 'Bs. 120',
          numericPrice: 120.0,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
        ),
      ];
    } else {
      return const [
        BusinessServiceItem(
          id: 'serv_gen_1',
          title: 'Masaje Relajante Antiestrés',
          description: 'Terapia corporal completa de 60 min con aceites esenciales.',
          price: 'Bs. 160',
          numericPrice: 160.0,
          imageUrl:
              'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_gen_2',
          title: 'Limpieza Facial Profunda',
          description: 'Exfoliación, vapor de ozono, extracción y mascarilla revitalizante.',
          price: 'Bs. 130',
          numericPrice: 130.0,
          imageUrl:
              'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_gen_3',
          title: 'Manicura & Pedicura Spa',
          description: 'Cuidado completo de uñas, exfoliación e hidratación intensiva.',
          price: 'Bs. 90',
          numericPrice: 90.0,
          imageUrl:
              'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=500&auto=format&fit=crop&q=60',
        ),
        BusinessServiceItem(
          id: 'serv_gen_4',
          title: 'Corte y Peinado Profesional',
          description: 'Estilismo personalizado según la forma y fisonomía de tu rostro.',
          price: 'Bs. 75',
          numericPrice: 75.0,
          imageUrl:
              'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&auto=format&fit=crop&q=60',
        ),
      ];
    }
  }

  /// Ofertas destacadas horizontales (como las del diseño del dentista)
  List<BusinessSpecialOfferItem> _getBusinessSpecialOffers() {
    final b = widget.business;
    final cat = b.category.toLowerCase();
    final name = b.name.toLowerCase();

    if (cat.contains('salud') || name.contains('dentista') || name.contains('dental')) {
      return const [
        BusinessSpecialOfferItem(
          id: 'off_dent_1',
          badge: 'Nuevo',
          discountHeadline: '2x1',
          title: 'Limpieza dental',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=500&auto=format&fit=crop&q=60',
          originalPrice: 'Bs. 130',
          offerPrice: 'Bs. 65',
        ),
        BusinessSpecialOfferItem(
          id: 'off_dent_2',
          badge: 'Nuevo',
          discountHeadline: '2x1',
          title: 'Limpieza dental',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=500&auto=format&fit=crop&q=60',
          originalPrice: 'Bs. 130',
          offerPrice: 'Bs. 65',
        ),
        BusinessSpecialOfferItem(
          id: 'off_dent_3',
          badge: 'Popular',
          discountHeadline: '-30%',
          title: 'Blanqueamiento',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=500&auto=format&fit=crop&q=60',
          originalPrice: 'Bs. 280',
          offerPrice: 'Bs. 195',
        ),
      ];
    } else if (cat.contains('comida') || name.contains('panadería')) {
      return const [
        BusinessSpecialOfferItem(
          id: 'off_food_1',
          badge: 'Nuevo',
          discountHeadline: '3x2',
          title: 'Pan de Molde Especial',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCaK7qX9esbBF3k-YBViYb_YW_faBxTxymDHrJ24RCEXzr3WLMDUnVng9ImkYbsXDuCdPrgplYUxbSAW069NLeDAPClRrQALICvtyHTPz9CRWhVFkvLP_4etWjyNsZrd2JK5nB_l9Jq76FiMBr6M2QL8X2l3AsQYnrdgQWJ63okpNIZoAwAZ7OcnWGH0kaNDZyBYNsNQMJU5a9vahexMcYAXCnUR5JsnzEruGYbSk8N7HIdGKy41CHVHw',
          originalPrice: 'Bs. 90',
          offerPrice: 'Bs. 60',
        ),
        BusinessSpecialOfferItem(
          id: 'off_food_2',
          badge: 'Nuevo',
          discountHeadline: '2x1',
          title: 'Croissants de Mantequilla',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA2hDU--JiWYBxdiotcwomQH2NkKz8K82Phos88gVa1mv4Eic-S0lMqcVj_6KjLvQXBMBu-idM2HLtN1M50Zs7DQXqTwws6bMaMa7pligXUQxG8ElJ0twZCINeU7pIr52bklJrBxbqEgs7L3aaRIMcjq86xafLyO8QzE2zfKnnKgFUXbQQ8gkH3eLEFBJZMcEgZbI0z1nJ1bboQ9_u8tp8kncN_gl_elsIm-rBRlIOf6r5rvhhE8SIvGQ',
          originalPrice: 'Bs. 40',
          offerPrice: 'Bs. 20',
        ),
      ];
    } else {
      return const [
        BusinessSpecialOfferItem(
          id: 'off_gen_1',
          badge: 'Nuevo',
          discountHeadline: '2x1',
          title: 'Pase de Entrenamiento',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
          originalPrice: 'Bs. 120',
          offerPrice: 'Bs. 60',
        ),
        BusinessSpecialOfferItem(
          id: 'off_gen_2',
          badge: 'Nuevo',
          discountHeadline: '-40%',
          title: 'Proteína Whey 2lb',
          timerBadge: 'Solo hoy',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
          originalPrice: 'Bs. 280',
          offerPrice: 'Bs. 168',
        ),
      ];
    }
  }

  List<BusinessProductItem> _getBusinessProducts() {
    final b = widget.business;

    if (b.category.toLowerCase().contains('comida') ||
        b.name.toLowerCase().contains('panadería')) {
      return const [
        BusinessProductItem(
          id: 'prod_1',
          title: 'Pan de Molde',
          price: 'Bs. 65',
          originalPrice: 'Bs 50',
          discount: '-15%',
          timer: '2:00',
          stock: 'Quedan 2',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCujNPFmhhL2pwel9ID-P0QFK_mKLWl02IXlUiLG59xcjf-RLs1u7tc9JwqwRN3UqabWDsX_b99SKYifo4peqXJryozIPufjUVsjisnmloNFeIdg0XsXUZ4zyuoS-XcofaKijJt6vl69NciiN6pfamMudLJTrPh2X3ynHnhTaraQ7bz-q5ZFXq7LvId2yt7SBUMUxrfYDciJOn5aBo4PjtI7M1iHvh_2_JUxyGpoYMexlhbEvmi3vQ-ww',
        ),
        BusinessProductItem(
          id: 'prod_2',
          title: 'Pan de Molde',
          price: 'Bs. 65',
          originalPrice: 'Bs 50',
          discount: '-15%',
          timer: '2:00',
          stock: 'Quedan 2',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCujNPFmhhL2pwel9ID-P0QFK_mKLWl02IXlUiLG59xcjf-RLs1u7tc9JwqwRN3UqabWDsX_b99SKYifo4peqXJryozIPufjUVsjisnmloNFeIdg0XsXUZ4zyuoS-XcofaKijJt6vl69NciiN6pfamMudLJTrPh2X3ynHnhTaraQ7bz-q5ZFXq7LvId2yt7SBUMUxrfYDciJOn5aBo4PjtI7M1iHvh_2_JUxyGpoYMexlhbEvmi3vQ-ww',
        ),
        BusinessProductItem(
          id: 'prod_3',
          title: 'Croissants de Mantequilla',
          price: 'Bs. 45',
          originalPrice: 'Bs 60',
          discount: '-25%',
          timer: '1:30',
          stock: 'Quedan 3',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA2hDU--JiWYBxdiotcwomQH2NkKz8K82Phos88gVa1mv4Eic-S0lMqcVj_6KjLvQXBMBu-idM2HLtN1M50Zs7DQXqTwws6bMaMa7pligXUQxG8ElJ0twZCINeU7pIr52bklJrBxbqEgs7L3aaRIMcjq86xafLyO8QzE2zfKnnKgFUXbQQ8gkH3eLEFBJZMcEgZbI0z1nJ1bboQ9_u8tp8kncN_gl_elsIm-rBRlIOf6r5rvhhE8SIvGQ',
        ),
        BusinessProductItem(
          id: 'prod_4',
          title: 'Empanadas de Queso',
          price: 'Bs. 30',
          originalPrice: 'Bs 40',
          discount: '-20%',
          timer: '2:00',
          stock: 'Quedan 5',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCArvZEJGhhh9Jrsr951Un-feWfD-bpN07EtcTRg0rdcETsLhIm2iQoqVZBw1Gyt3cYmeVOO_SjcAWqbJNs3121j0ph8LBYM4leRMhS1KT4TbkmfvKh3U73Qfb_0Bk7SJiUVl2ceC9n_2QKrdaxUlXHevkvtRYlNBxx88_83nsekig3sGgomar70Onr4DYnVXaNds5qlh_Xrfb885o8Q3G2gwT3JdQk0McgX7RYJA0aRzzX5AFHZboFFA',
        ),
        BusinessProductItem(
          id: 'prod_5',
          title: 'Donas Glaseadas x6',
          price: 'Bs. 35',
          originalPrice: 'Bs 45',
          discount: '-22%',
          timer: '0:45',
          stock: 'Quedan 3',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDYAyuQG0G0SPNOFBIKINQmfAop2-uaecRghpEdOt03PMPJ4fBu6nG4B4EOxH0OuWi9fM8W8uBiiRp-95yRXt9HuPZnCG6x1lO6-NMcgxUai2d-I8aU0TExx1COYM5XHQWo2NIL8yTKXSGFLgE0IdWZ8A0UWi8Q4WK_NlGqX-QBgDzBXWBa7-wxeOS6deAV9T7ojS-jqqSd8GbDUaZCFS2X5-05BRPZINVrCpq2coKiVG8rjxdu0oTztg',
        ),
        BusinessProductItem(
          id: 'prod_6',
          title: 'Tarta de Frutillas',
          price: 'Bs. 55',
          originalPrice: 'Bs 70',
          discount: '-21%',
          timer: '1:15',
          stock: 'Quedan 1',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCaK7qX9esbBF3k-YBViYb_YW_faBxTxymDHrJ24RCEXzr3WLMDUnVng9ImkYbsXDuCdPrgplYUxbSAW069NLeDAPClRrQALICvtyHTPz9CRWhVFkvLP_4etWjyNsZrd2JK5nB_l9Jq76FiMBr6M2QL8X2l3AsQYnrdgQWJ63okpNIZoAwAZ7OcnWGH0kaNDZyBYNsNQMJU5a9vahexMcYAXCnUR5JsnzEruGYbSk8N7HIdGKy41CHVHw',
        ),
      ];
    } else {
      return const [
        BusinessProductItem(
          id: 'prod_fit_1',
          title: 'Pase Libre Mensual',
          price: 'Bs. 180',
          originalPrice: 'Bs 250',
          discount: '-28%',
          timer: '2:00',
          stock: 'Quedan 4',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        ),
        BusinessProductItem(
          id: 'prod_fit_2',
          title: 'Proteína Whey 2lb',
          price: 'Bs. 220',
          originalPrice: 'Bs 280',
          discount: '-20%',
          timer: '1:30',
          stock: 'Quedan 2',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
        ),
        BusinessProductItem(
          id: 'prod_fit_3',
          title: 'Creatina Monohidratada',
          price: 'Bs. 130',
          originalPrice: 'Bs 160',
          discount: '-18%',
          timer: '1:00',
          stock: 'Quedan 5',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
        ),
        BusinessProductItem(
          id: 'prod_fit_4',
          title: 'Shaker Pro 700ml',
          price: 'Bs. 35',
          originalPrice: 'Bs 50',
          discount: '-30%',
          timer: '2:30',
          stock: 'Quedan 8',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
        ),
      ];
    }
  }

  void _openReviewModal() {
    final reviewController = TextEditingController();
    int rating = 5;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deja tu opinión sobre ${widget.business.name}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setModalState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFEB700),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reviewController,
                maxLines: 3,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
                decoration: InputDecoration(
                  hintText: 'Cuéntanos tu experiencia con este negocio...',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                  ),
                  filled: isDark,
                  fillColor: isDark ? AppColors.darkCardAlt : Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFD1D5DB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '¡Gracias por tu opinión! Se ha publicado con éxito.',
                        ),
                        backgroundColor: Color(0xFF22C55E),
                      ),
                    );
                  },
                  child: Text(
                    'Publicar Reseña',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final products = _getBusinessProducts();
    final services = _getBusinessServices();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Portada con Carrusel e Interacciones
            _buildCoverHeader(b),

            // 2. Información del Negocio y Botones Principales
            _buildBusinessInfo(b),

            // 3. Ofertas Especiales Destacadas (Tarjetas Horizontales con 2x1 y Nuevo)
            _buildSpecialOffersSection(b),

            // 4. Indicador / Sugerencia de Selección Táctil
            _buildSelectionHint(),

            // 5. Pestañas de Catálogo (🔥 Ofertas flash | Productos | Servicios)
            _buildCatalogTabs(),

            // 6. Contenido del Catálogo según pestaña activa
            if (_selectedCatalogTab == 2)
              _buildServicesList(services)
            else
              _buildProductGrid(products),

            // 7. Sección de Opiniones y Reseñas de Clientes
            _buildReviewsSection(b),

            // 8. Botones de Redes Sociales
            _buildSocialFooter(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      // Botón flotante para consultar por WhatsApp los servicios seleccionados
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedServiceIds.isEmpty
          ? null
          : _buildFloatingWhatsAppButton(b, services),
    );
  }

  List<String> _getCoverImages(BusinessModel b) {
    if (b.photoUrls.isNotEmpty) {
      return b.photoUrls;
    }
    if (b.imageUrl.isNotEmpty) {
      if (b.category.toLowerCase().contains('salud') ||
          b.name.toLowerCase().contains('dentista') ||
          b.name.toLowerCase().contains('spa')) {
        return [
          b.imageUrl,
          'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=600&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=600&auto=format&fit=crop&q=80',
        ];
      } else if (b.category.toLowerCase().contains('comida') ||
          b.name.toLowerCase().contains('pizza') ||
          b.name.toLowerCase().contains('café') ||
          b.name.toLowerCase().contains('burger')) {
        return [
          b.imageUrl,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDa_GjJLeIkJpaN8Aq5F5gwAFE80r0L6l-4e3R0v2b4uMTgNAQYafhjr4kCyoH9ITj3n377qDs7FMrhg9TVYivy691f9XwS15nObZYssq5R8JomhyCK-Mo4wLPqFthSOdrBWQMc4_7djZn-pABc8MsYzk93dReSeLambeqJl7Y31VlJegBLi7AXEbzdhpmBJT3Dif5aSSXLw9QxSOFNYuNkIGNOqasEWTVW_f4EqrZSJMskF8s_aC3m3g',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBWoGdKRNB1JG2mY7fohgvjDZrpYCn4IPucG4xKkSeWy6t7PHeUOrdv1I4m15oeBwKD8zj7B5-5-BVWI4Vlv2fNGvpaXChiWDHPClABJ2vXbk9tJmORrufb2X-O1aQe55bs77SJjenACanxbXJBeEaodJpv3xqX1SsH6vlS_alo0oa7stj8i03vTii6nZnw8021-3P8U5Fiv6cvOZHzEwd9xF91b3HahskVBJsXGdEQBZzjwukmX3Mi-Q',
        ];
      } else {
        return [
          b.imageUrl,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
        ];
      }
    }
    return const [];
  }

  Widget _buildCoverHeader(BusinessModel b) {
    final images = _getCoverImages(b);

    return Stack(
      children: [
        // Interactive Cover Carousel
        SizedBox(
          width: double.infinity,
          height: 280,
          child: images.isEmpty
              ? Container(
                  color: const Color(0xFFE5E7EB),
                  child: Icon(
                    b.categoryIcon,
                    size: 60,
                    color: const Color(0xFF9CA3AF),
                  ),
                )
              : PageView.builder(
                  controller: _coverPageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCoverIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final imgUrl = images[index];
                    return Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5E7EB),
                        child: Icon(
                          b.categoryIcon,
                          size: 60,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Gradient for Top Button Contrast
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Gradient for Carousel Dots Contrast
        if (images.length > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // Top Navigation Buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleBusinessFavorite,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isFavorite
                              ? const Color(0xFFEF233C)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Enlace de ${b.name} copiado para compartir 🔗',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Interactive Carousel Pagination Dots
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isSelected = index == _currentCoverIndex;
                return GestureDetector(
                  onTap: () {
                    _coverPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

        // Photo Counter Badge
        if (images.length > 1)
          Positioned(
            bottom: 8,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentCoverIndex + 1}/${images.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBusinessInfo(BusinessModel b) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Frase destacada o eslogan del negocio
    final slogan = b.name.toLowerCase().contains('dentista')
        ? '“Dentista con atención cercana y precios accesibles.”'
        : (b.description.isNotEmpty ? '“${b.description}”' : '“Calidad garantizada y atención personalizada.”');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            b.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Rating & Reviews Row
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: index < 4
                        ? const Color(0xFFFEB700)
                        : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  );
                }),
              ),
              const SizedBox(width: 6),
              Text(
                b.rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              Text(
                ' (${b.reviewsCount} opiniones)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Location Info (Opens Google Maps directly)
          GestureDetector(
            onTap: () => MapLauncherService.openMapWithCoordinates(
              b.latitude,
              b.longitude,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${b.address} · ${b.distance}',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Working Hours Status (Interactive)
          InkWell(
            onTap: () => BusinessScheduleBottomSheet.show(context, b),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 16,
                    color: b.isCurrentlyOpenNow
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    b.isCurrentlyOpenNow ? 'Abierto' : 'Cerrado',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: b.isCurrentlyOpenNow
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  Text(
                    ' · ${b.scheduleStatusSubtitle}',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Seguir & WhatsApp
          Row(
            children: [
              // Follow Button
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _toggleFollow,
                    icon: Icon(
                      _isFollowing
                          ? Icons.check_rounded
                          : Icons.person_add_rounded,
                      size: 18,
                      color: _isFollowing
                          ? const Color(0xFF10B981)
                          : (isDark ? const Color(0xFFC084FC) : const Color(0xFF8C4FF6)),
                    ),
                    label: Text(
                      _isFollowing ? 'Siguiendo' : '+ Seguir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _isFollowing
                            ? const Color(0xFF10B981)
                            : (isDark ? const Color(0xFFC084FC) : const Color(0xFF8C4FF6)),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isFollowing
                            ? const Color(0xFF10B981)
                            : (isDark ? const Color(0xFF8C4FF6) : const Color(0xFFC084FC)),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Direct WhatsApp Button
              Expanded(
                child: WhatsAppButton(
                  phoneNumber: b.phoneNumber,
                  businessName: b.name,
                  label: 'WhatsApp',
                  height: 44,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Slogan / Quote
          Center(
            child: Text(
              slogan,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección horizontal de Ofertas Especiales (con 2x1, Limpieza dental, Solo hoy)
  Widget _buildSpecialOffersSection(BusinessModel b) {
    final offers = _getBusinessSpecialOffers();
    if (offers.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Ofertas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: 0.78,
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: Color(0xFF8C4FF6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ofertas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    OfferDetailBottomSheet.show(
                      context,
                      title: offers.first.title,
                      subtitle: 'Oferta especial en ${b.name}',
                      businessCategory: b.category,
                      price: offers.first.discountHeadline,
                      originalPrice: offers.first.originalPrice,
                      timerRemaining: offers.first.timerBadge,
                      stockRemaining: 'Disponible',
                      validUntil: 'Válido hoy',
                      imageUrl: offers.first.imageUrl,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Ver todas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8C4FF6),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: Color(0xFF8C4FF6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Carrusel horizontal de tarjetas de oferta
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: offers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final offer = offers[index];
                final isFav = FavoritesService.instance.isOfferFavorite(offer.id);

                return GestureDetector(
                  onTap: () {
                    OfferDetailBottomSheet.show(
                      context,
                      title: offer.title,
                      subtitle: 'Promoción destacada en ${b.name}',
                      businessCategory: b.category,
                      price: offer.discountHeadline,
                      originalPrice: offer.originalPrice,
                      timerRemaining: offer.timerBadge,
                      stockRemaining: 'Disponible',
                      validUntil: 'Válido hoy',
                      imageUrl: offer.imageUrl,
                    );
                  },
                  child: Container(
                    width: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Imagen de Fondo
                          Image.network(
                            offer.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Color(0xFF9CA3AF),
                                size: 40,
                              ),
                            ),
                          ),

                          // Degradado Oscuro en la base para legibilidad
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),

                          // Tag "Nuevo" (Verde arriba a la izquierda)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer.badge,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Corazón de Favorito (Arriba a la derecha)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _toggleOfferFavorite(offer),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isFav
                                      ? const Color(0xFFEF233C)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Contenido de Texto y Cápsula Inferior
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Titular grande (ej. 2x1)
                                Text(
                                  offer.discountHeadline,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Subtítulo (ej. Limpieza dental)
                                Text(
                                  offer.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // Cápsula "Solo hoy" con reloj rojo
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time_filled_rounded,
                                        size: 13,
                                        color: Color(0xFFDC2626),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          offer.timerBadge,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFDC2626),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Banner indicador de Selección Táctil verde
  Widget _buildSelectionHint() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 18,
            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Selecciona lo que te interesa para consultar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Pestañas de navegación de catálogo: Ofertas flash, Productos, Servicios
  Widget _buildCatalogTabs() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Tab 1: Ofertas Flash
          GestureDetector(
            onTap: () => setState(() => _selectedCatalogTab = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCatalogTab == 0
                    ? const Color(0xFFEF4444)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    'Ofertas flash',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _selectedCatalogTab == 0
                          ? Colors.white
                          : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF1B1C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tab 2: Productos
          GestureDetector(
            onTap: () => setState(() => _selectedCatalogTab = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCatalogTab == 1
                    ? const Color(0xFFA855F7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Productos',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _selectedCatalogTab == 1
                      ? Colors.white
                      : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF1B1C1C)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tab 3: Servicios (Activo en el diseño de referencia)
          GestureDetector(
            onTap: () => setState(() => _selectedCatalogTab = 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCatalogTab == 2
                    ? const Color(0xFFA855F7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Servicios',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _selectedCatalogTab == 2
                      ? Colors.white
                      : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF1B1C1C)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lista estructurada de Servicios con selección interactiva y estilo Lavanda
  Widget _buildServicesList(List<BusinessServiceItem> services) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Text(
            'No hay servicios disponibles por el momento.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedServiceIds.contains(service.id);
        final isServiceFav = FavoritesService.instance.isServiceFavorite(service.id);

        return GestureDetector(
          key: Key('service_item_${service.id}'),
          onTap: () => _toggleServiceSelection(service.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Fondo lavanda suave al estar seleccionado
              color: isSelected
                  ? (isDark ? const Color(0xFF3B1D61) : const Color(0xFFF5EEFD))
                  : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? const Color(0xFFC084FC) : const Color(0xFFD8B4FE))
                    : (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0x1EA855F7)
                      : (isDark ? const Color(0x22000000) : const Color(0x06000000)),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Miniatura del servicio
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 66,
                    height: 66,
                    child: Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? AppColors.darkCardAlt : const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Título y Descripción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        service.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Precio y botón de favorito
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service.price,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF1B1C1C),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Color(0xFF8C4FF6),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleServiceFavorite(service),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isServiceFav
                              ? const Color(0xFFEF233C).withValues(alpha: 0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isServiceFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isServiceFav
                              ? const Color(0xFFEF233C)
                              : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Grilla de Productos y Ofertas Flash
  Widget _buildProductGrid(List<BusinessProductItem> products) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (context, index) {
          final prod = products[index];
          final isFav = FavoritesService.instance.isProductFavorite(prod.id);

          return GestureDetector(
            onTap: () {
              OfferDetailBottomSheet.show(
                context,
                title: prod.title,
                subtitle: 'Oferta exclusiva en ${widget.business.name}',
                businessCategory: widget.business.category,
                price: prod.price,
                originalPrice: prod.originalPrice,
                discountBadge: prod.discount,
                timerRemaining: prod.timer,
                stockRemaining: prod.stock,
                validUntil: 'Válido hoy',
                imageUrl: prod.imageUrl,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Badges
                AspectRatio(
                  aspectRatio: 1.15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          prod.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppColors.darkCardAlt : const Color(0xFFF3F4F6),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 32,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        // Top-Left Discount Badge
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF331F),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              prod.discount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // Top-Right Favorite Heart
                          Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleProductFavorite(prod),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: isFav
                                  ? const Color(0xFFEF233C)
                                  : (isDark ? Colors.white70 : Colors.black),
                            ),
                          ),
                        ),
                        // Center Timer Badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF331F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  prod.timer,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom-Right Stock Badge
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              prod.stock,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Pricing Row
                Row(
                  children: [
                    Text(
                      prod.price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFC084FC) : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prod.originalPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9CA3AF),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Title
                Text(
                  prod.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Botón flotante verde de WhatsApp con conteo dinámico
  Widget _buildFloatingWhatsAppButton(
    BusinessModel b,
    List<BusinessServiceItem> services,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4022C55E),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _consultSelectedServicesViaWhatsApp(b, services),
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono WhatsApp
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF22C55E),
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Consultar por WhatsApp (${_selectedServiceIds.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sección de Opiniones con tarjeta de Aldaris y 3 indicadores de puntos
  Widget _buildReviewsSection(BusinessModel b) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opiniones',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              GestureDetector(
                onTap: _openReviewModal,
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8C4FF6),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: Color(0xFF8C4FF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tarjeta de Reseña de Aldaris
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar con "A" púrpura
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA855F7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nombre, fecha y estrellas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Aldaris',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                                ),
                              ),
                              Row(
                                children: List.generate(4, (index) {
                                  return const Icon(
                                    Icons.star_rounded,
                                    size: 17,
                                    color: Color(0xFFFEB700),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hace 2 días',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Texto testimonial
                Text(
                  b.category.toLowerCase().contains('salud') || b.name.toLowerCase().contains('dentista')
                      ? '“Muy buena atención y excelente servicio profesional, volvería sin duda.”'
                      : '“Muy rica la comida y buena atención, volvería sin duda.”',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Indicador de 3 puntos del testimonio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer con Botones Sociales (Facebook, TikTok, Instagram, WWW)
  Widget _buildSocialFooter() {
    final b = widget.business;
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              color: const Color(0xFF1877F2),
              icon: Icons.facebook,
              tooltip: 'Facebook',
              onTap: () => SocialLauncherService.openFacebook(
                context,
                b.facebook,
                businessName: b.name,
              ),
            ),
            const SizedBox(width: 14),
            _buildSocialButton(
              color: const Color(0xFF1B1C1C),
              icon: Icons.music_note_rounded,
              tooltip: 'TikTok',
              onTap: () => SocialLauncherService.openTikTok(
                context,
                b.tiktok,
                businessName: b.name,
              ),
            ),
            const SizedBox(width: 14),
            _buildInstagramButton(
              tooltip: 'Instagram',
              onTap: () => SocialLauncherService.openInstagram(
                context,
                b.instagram,
                businessName: b.name,
              ),
            ),
            const SizedBox(width: 14),
            _buildWwwButton(
              tooltip: 'Página Web',
              onTap: () => SocialLauncherService.openWebsite(
                context,
                b.website,
                businessName: b.name,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Color color,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramButton({
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(-0.8, 0.8),
                radius: 1.2,
                colors: [
                  Color(0xFFFDF497),
                  Color(0xFFFD5949),
                  Color(0xFFD6249F),
                  Color(0xFF285AEB),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWwwButton({
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border.all(
                color: isDark ? const Color(0xFF6B7280) : const Color(0xFF1F2937),
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x22000000) : const Color(0x0E000000),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 14,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
                Text(
                  'WWW',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
