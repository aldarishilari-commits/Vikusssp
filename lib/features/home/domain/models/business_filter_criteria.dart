/// Niveles de precio para clasificar y filtrar comercios
enum PriceLevel {
  economic, // Económico ($)
  medium,   // Medio ($$)
  premium,  // Premium ($$$)
}

extension PriceLevelExtension on PriceLevel {
  String get label {
    switch (this) {
      case PriceLevel.economic:
        return 'Económico (\$)';
      case PriceLevel.medium:
        return 'Medio (\$\$)';
      case PriceLevel.premium:
        return 'Premium (\$\$\$)';
    }
  }

  String get shortSymbol {
    switch (this) {
      case PriceLevel.economic:
        return '\$';
      case PriceLevel.medium:
        return '\$\$';
      case PriceLevel.premium:
        return '\$\$\$';
    }
  }
}

/// Modelo que encapsula todos los criterios de filtrado seleccionados por el usuario
class BusinessFilterCriteria {
  double? maxDistanceKm; // null = Sin límite (muestra todos los negocios ordenados por menor distancia)
  bool onlyOpen;
  bool onlyOffers;
  Set<PriceLevel> selectedPrices;

  static const double defaultMaxDistance = 5.0;

  BusinessFilterCriteria({
    this.maxDistanceKm,
    this.onlyOpen = false,
    this.onlyOffers = false,
    Set<PriceLevel>? selectedPrices,
  }) : selectedPrices = selectedPrices ?? {};

  /// Indica si hay algún filtro activo que difiera del valor por defecto
  bool get hasActiveFilters =>
      maxDistanceKm != null ||
      onlyOpen ||
      onlyOffers ||
      selectedPrices.isNotEmpty;

  /// Cantidad de filtros aplicados
  int get activeFilterCount {
    int count = 0;
    if (maxDistanceKm != null) count++;
    if (onlyOpen) count++;
    if (onlyOffers) count++;
    if (selectedPrices.isNotEmpty) count++;
    return count;
  }

  /// Restablece todos los filtros a su estado inicial (sin límite de distancia)
  void clear() {
    maxDistanceKm = null;
    onlyOpen = false;
    onlyOffers = false;
    selectedPrices.clear();
  }

  /// Crea una copia independiente para manipular antes de aplicar
  BusinessFilterCriteria clone() {
    return BusinessFilterCriteria(
      maxDistanceKm: maxDistanceKm,
      onlyOpen: onlyOpen,
      onlyOffers: onlyOffers,
      selectedPrices: Set.from(selectedPrices),
    );
  }

  BusinessFilterCriteria copyWith({
    double? maxDistanceKm,
    bool clearMaxDistance = false,
    bool? onlyOpen,
    bool? onlyOffers,
    Set<PriceLevel>? selectedPrices,
  }) {
    return BusinessFilterCriteria(
      maxDistanceKm: clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      onlyOpen: onlyOpen ?? this.onlyOpen,
      onlyOffers: onlyOffers ?? this.onlyOffers,
      selectedPrices: selectedPrices ?? Set.from(this.selectedPrices),
    );
  }
}
