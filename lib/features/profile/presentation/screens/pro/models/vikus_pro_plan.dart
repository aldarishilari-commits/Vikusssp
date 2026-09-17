class VikusProPlan {
  final String id;
  final String title;
  final double price;
  final String priceFormatted;
  final String periodLabel;
  final String? badge;
  final bool isPopular;

  const VikusProPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.priceFormatted,
    required this.periodLabel,
    this.badge,
    this.isPopular = false,
  });

  static const List<VikusProPlan> availablePlans = [
    VikusProPlan(
      id: 'monthly',
      title: 'Mensual',
      price: 15.0,
      priceFormatted: '15,00 Bs',
      periodLabel: '15 Bs/mes',
      badge: 'Más popular',
      isPopular: true,
    ),
    VikusProPlan(
      id: 'quarterly',
      title: 'Trimestral',
      price: 42.0,
      priceFormatted: '42,00 Bs',
      periodLabel: '42 Bs/3 meses',
      badge: 'Ahorra 7%',
      isPopular: false,
    ),
    VikusProPlan(
      id: 'annual',
      title: 'Anual',
      price: 150.0,
      priceFormatted: '150,00 Bs',
      periodLabel: '150 Bs/Anual',
      badge: 'Ahorra 17%',
      isPopular: false,
    ),
  ];
}
