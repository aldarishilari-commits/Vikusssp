import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/home/domain/models/business_filter_criteria.dart';
import 'package:aeronpulse/features/home/presentation/widgets/business_card_item.dart';

void main() {
  group('BusinessFilterCriteria Tests', () {
    test('Default criteria has no active filters', () {
      final criteria = BusinessFilterCriteria();
      expect(criteria.hasActiveFilters, isFalse);
      expect(criteria.activeFilterCount, 0);
      expect(criteria.maxDistanceKm, isNull);
      expect(criteria.onlyOpen, isFalse);
      expect(criteria.onlyOffers, isFalse);
      expect(criteria.selectedPrices, isEmpty);
    });

    test('Modifying criteria updates activeFilterCount and hasActiveFilters', () {
      final criteria = BusinessFilterCriteria(
        maxDistanceKm: 2.0,
        onlyOpen: true,
        onlyOffers: true,
        selectedPrices: {PriceLevel.economic},
      );

      expect(criteria.hasActiveFilters, isTrue);
      expect(criteria.activeFilterCount, 4);

      criteria.clear();
      expect(criteria.hasActiveFilters, isFalse);
      expect(criteria.activeFilterCount, 0);
    });

    test('BusinessModel matchesFilter evaluates distance, open, offers and price correctly', () {
      const biz1 = BusinessModel(
        id: '1',
        name: 'Gym',
        category: 'Deporte',
        description: 'Gym',
        address: 'Av. Pando',
        distance: '300 m',
        distanceKm: 0.3,
        isOpen: true,
        closingTime: '23:59',
        promoBadge: 'OFERTA',
        imageUrl: '',
        priceLevel: PriceLevel.economic,
      );

      const biz2 = BusinessModel(
        id: '2',
        name: 'Restaurant',
        category: 'Comida',
        description: 'Rest',
        address: 'Av. Principal',
        distance: '3.5 km',
        distanceKm: 3.5,
        isOpen: false,
        promoBadge: null,
        imageUrl: '',
        priceLevel: PriceLevel.premium,
      );

      // Default criteria: both match
      final defaultCriteria = BusinessFilterCriteria();
      expect(biz1.matchesFilter(defaultCriteria), isTrue);
      expect(biz2.matchesFilter(defaultCriteria), isTrue);

      // Distance filter <= 1.0 km
      final distCriteria = BusinessFilterCriteria(maxDistanceKm: 1.0);
      expect(biz1.matchesFilter(distCriteria), isTrue);
      expect(biz2.matchesFilter(distCriteria), isFalse);

      // Only open
      final openCriteria = BusinessFilterCriteria(onlyOpen: true);
      expect(biz1.matchesFilter(openCriteria), isTrue);
      expect(biz2.matchesFilter(openCriteria), isFalse);

      // Only offers
      final offersCriteria = BusinessFilterCriteria(onlyOffers: true);
      expect(biz1.matchesFilter(offersCriteria), isTrue);
      expect(biz2.matchesFilter(offersCriteria), isFalse);

      // Price filter
      final priceCriteria = BusinessFilterCriteria(
        selectedPrices: {PriceLevel.economic},
      );
      expect(biz1.matchesFilter(priceCriteria), isTrue);
      expect(biz2.matchesFilter(priceCriteria), isFalse);
    });
  });
}
