import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/core/services/location_service.dart';
import 'package:aeronpulse/features/home/domain/models/business_filter_criteria.dart';
import 'package:aeronpulse/features/home/presentation/widgets/business_card_item.dart';

void main() {
  group('Distance Filtering and Ascending Sorting Tests', () {
    // Coordenadas de referencia del usuario (Centro de La Paz)
    const double userLat = -16.5000;
    const double userLng = -68.1250;

    // Negocios con coordenadas registradas a distintas distancias
    final List<BusinessModel> testBusinesses = [
      const BusinessModel(
        id: 'biz_d',
        name: 'Negocio D',
        category: 'Deporte',
        description: 'Negocio a 2.8 km',
        address: 'Av. Pando',
        distance: '',
        latitude: -16.5220,
        longitude: -68.1380,
        imageUrl: '',
      ),
      const BusinessModel(
        id: 'biz_a',
        name: 'Negocio A',
        category: 'Deporte',
        description: 'Negocio a 300 m (0.3 km)',
        address: 'Av. Pando',
        distance: '',
        latitude: -16.5020,
        longitude: -68.1235,
        imageUrl: '',
      ),
      const BusinessModel(
        id: 'biz_e_far',
        name: 'Negocio E (Lejano 3.5 km)',
        category: 'Comida',
        description: 'Negocio a 3.5 km',
        address: 'Calle 21',
        distance: '',
        latitude: -16.5280,
        longitude: -68.1420,
        imageUrl: '',
      ),
      const BusinessModel(
        id: 'biz_b',
        name: 'Negocio B',
        category: 'Deporte',
        description: 'Negocio a 600 m (0.6 km)',
        address: 'Av. Pando',
        distance: '',
        latitude: -16.5045,
        longitude: -68.1270,
        imageUrl: '',
      ),
      const BusinessModel(
        id: 'biz_c',
        name: 'Negocio C',
        category: 'Comida',
        description: 'Negocio a 1.2 km',
        address: 'Av. Principal',
        distance: '',
        latitude: -16.5090,
        longitude: -68.1310,
        imageUrl: '',
      ),
    ];

    test('Calculates real GPS distance accurately for each business', () {
      final updated = testBusinesses.map((b) {
        final distMeters = LocationService.calculateDistanceInMeters(
          startLatitude: userLat,
          startLongitude: userLng,
          endLatitude: b.latitude,
          endLongitude: b.longitude,
        );
        final distKm = distMeters / 1000.0;
        final formatted = LocationService.formatDistance(distMeters);
        return b.copyWith(distanceKm: distKm, distance: formatted);
      }).toList();

      final bizA = updated.firstWhere((b) => b.id == 'biz_a');
      final bizB = updated.firstWhere((b) => b.id == 'biz_b');
      final bizC = updated.firstWhere((b) => b.id == 'biz_c');
      final bizD = updated.firstWhere((b) => b.id == 'biz_d');
      final bizE = updated.firstWhere((b) => b.id == 'biz_e_far');

      expect(bizA.distanceKm, closeTo(0.3, 0.15));
      expect(bizB.distanceKm, closeTo(0.6, 0.15));
      expect(bizC.distanceKm, closeTo(1.2, 0.25));
      expect(bizD.distanceKm, closeTo(2.8, 0.4));
      expect(bizE.distanceKm, closeTo(3.5, 0.5));
    });

    test('Filtering with 3.0 km excludes businesses > 3.0 km and sorts ascending (closest -> farthest)', () {
      // 1. Recalcular distancias según coordenadas del usuario
      final withDistances = testBusinesses.map((b) {
        final distMeters = LocationService.calculateDistanceInMeters(
          startLatitude: userLat,
          startLongitude: userLng,
          endLatitude: b.latitude,
          endLongitude: b.longitude,
        );
        return b.copyWith(
          distanceKm: distMeters / 1000.0,
          distance: LocationService.formatDistance(distMeters),
        );
      }).toList();

      // 2. Aplicar filtro de 3.0 km
      final criteria = BusinessFilterCriteria(maxDistanceKm: 3.0);
      final filtered = withDistances.where((b) => b.matchesFilter(criteria)).toList();

      // 3. Ordenar ascendentemente por distancia
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      // Negocio E (> 3.0 km) debe ser excluido
      expect(filtered.any((b) => b.id == 'biz_e_far'), isFalse);
      expect(filtered.length, 4);

      // Los resultados deben aparecer ordenados de menor a mayor
      expect(filtered[0].id, 'biz_a'); // ~0.3 km
      expect(filtered[1].id, 'biz_b'); // ~0.6 km
      expect(filtered[2].id, 'biz_c'); // ~1.2 km
      expect(filtered[3].id, 'biz_d'); // ~2.8 km

      // Verificar que cada distancia es estrictamente menor o igual que la siguiente
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(filtered[i].distanceKm <= filtered[i + 1].distanceKm, isTrue);
      }
    });

    test('Filtering with 1.0 km shows only businesses <= 1.0 km sorted ascending', () {
      final withDistances = testBusinesses.map((b) {
        final distMeters = LocationService.calculateDistanceInMeters(
          startLatitude: userLat,
          startLongitude: userLng,
          endLatitude: b.latitude,
          endLongitude: b.longitude,
        );
        return b.copyWith(
          distanceKm: distMeters / 1000.0,
          distance: LocationService.formatDistance(distMeters),
        );
      }).toList();

      final criteria = BusinessFilterCriteria(maxDistanceKm: 1.0);
      final filtered = withDistances.where((b) => b.matchesFilter(criteria)).toList();
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      expect(filtered.length, 2);
      expect(filtered[0].id, 'biz_a');
      expect(filtered[1].id, 'biz_b');
      expect(filtered[0].distanceKm < filtered[1].distanceKm, isTrue);
    });

    test('Filtering with onlyOpen = true shows strictly open businesses', () {
      final List<BusinessModel> sampleBusinesses = [
        const BusinessModel(
          id: 'biz_open_1',
          name: 'Restaurante Abierto 1',
          category: 'Comida',
          description: 'Abierto',
          address: 'Av. 1',
          distance: '',
          isOpen: true,
          closingTime: '23:59',
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_closed_1',
          name: 'Restaurante Cerrado 1',
          category: 'Comida',
          description: 'Cerrado temporalmente',
          address: 'Av. 2',
          distance: '',
          isOpen: false,
          closingTime: '23:59',
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_open_2',
          name: 'Gimnasio Abierto 2',
          category: 'Deporte',
          description: 'Abierto',
          address: 'Av. 3',
          distance: '',
          isOpen: true,
          closingTime: '23:59',
          imageUrl: '',
        ),
      ];

      // Sin filtro de abierto (muestra todos: 3)
      final criteriaAll = BusinessFilterCriteria(onlyOpen: false);
      final listAll = sampleBusinesses.where((b) => b.matchesFilter(criteriaAll)).toList();
      expect(listAll.length, 3);

      // Con filtro onlyOpen = true (muestra solo los 2 abiertos)
      final criteriaOpen = BusinessFilterCriteria(onlyOpen: true);
      final listOpen = sampleBusinesses.where((b) => b.matchesFilter(criteriaOpen)).toList();
      expect(listOpen.length, 2);
      expect(listOpen.any((b) => b.id == 'biz_closed_1'), isFalse);
      expect(listOpen.map((b) => b.id).toList(), ['biz_open_1', 'biz_open_2']);
    });

    test('Combining onlyOpen = true and maxDistanceKm correctly filters both conditions', () {
      final List<BusinessModel> mixedBusinesses = [
        const BusinessModel(
          id: 'biz_near_open',
          name: 'Cercano y Abierto',
          category: 'Comida',
          description: '0.4 km',
          address: 'Av. 1',
          distance: '',
          distanceKm: 0.4,
          isOpen: true,
          closingTime: '23:59',
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_near_closed',
          name: 'Cercano y Cerrado',
          category: 'Comida',
          description: '0.5 km',
          address: 'Av. 2',
          distance: '',
          distanceKm: 0.5,
          isOpen: false,
          closingTime: '23:59',
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_far_open',
          name: 'Lejano y Abierto',
          category: 'Comida',
          description: '4.5 km',
          address: 'Av. 3',
          distance: '',
          distanceKm: 4.5,
          isOpen: true,
          closingTime: '23:59',
          imageUrl: '',
        ),
      ];

      final criteria = BusinessFilterCriteria(
        maxDistanceKm: 2.0,
        onlyOpen: true,
      );

      final result = mixedBusinesses.where((b) => b.matchesFilter(criteria)).toList();

      expect(result.length, 1);
      expect(result.first.id, 'biz_near_open');
    });

    test('Option 2: Default filter criteria has no distance limit and returns all businesses sorted by proximity', () {
      final List<BusinessModel> remoteBusinesses = [
        const BusinessModel(
          id: 'biz_12km',
          name: 'Negocio a 12 km',
          category: 'Comida',
          description: '12 km',
          address: 'Calle 50',
          distance: '',
          distanceKm: 12.0,
          isOpen: true,
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_6km',
          name: 'Negocio a 6 km',
          category: 'Comida',
          description: '6 km',
          address: 'Av. Circunvalación',
          distance: '',
          distanceKm: 6.0,
          isOpen: true,
          imageUrl: '',
        ),
        const BusinessModel(
          id: 'biz_25km',
          name: 'Negocio a 25 km',
          category: 'Deporte',
          description: '25 km',
          address: 'Zona Sur',
          distance: '',
          distanceKm: 25.0,
          isOpen: true,
          imageUrl: '',
        ),
      ];

      // Criterios por defecto (maxDistanceKm == null)
      final defaultCriteria = BusinessFilterCriteria();
      expect(defaultCriteria.maxDistanceKm, isNull);
      expect(defaultCriteria.hasActiveFilters, isFalse);

      final filtered = remoteBusinesses.where((b) => b.matchesFilter(defaultCriteria)).toList();
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      // Todos los negocios deben ser mostrados y ordenados de menor a mayor distancia
      expect(filtered.length, 3);
      expect(filtered[0].id, 'biz_6km');  // 6.0 km
      expect(filtered[1].id, 'biz_12km'); // 12.0 km
      expect(filtered[2].id, 'biz_25km'); // 25.0 km
    });
  });
}


