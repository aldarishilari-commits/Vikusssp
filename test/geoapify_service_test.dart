import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aeronpulse/core/services/geoapify_service.dart';

void main() {
  group('GeoapifyService formatting tests', () {
    test('formats address with street, number and suburb correctly', () {
      final props = {
        'street': 'Avenida Sánchez Bustamante',
        'housenumber': '8017',
        'suburb': 'Calacoto',
        'city': 'Municipio Nuestra Señora de La Paz',
        'formatted': 'Avenida Sánchez Bustamante 8017, Calacoto, Bolivia',
      };

      final address = GeoapifyService.formatAddress(props);
      expect(address, 'Avenida Sánchez Bustamante 8017, Calacoto');
    });

    test('formats address with venue name, street and suburb correctly', () {
      final props = {
        'name': 'Librería América',
        'street': 'Avenida Simón Bolívar',
        'suburb': 'Miraflores',
        'formatted':
            'Librería América, Avenida Simón Bolívar, Miraflores, Bolivia',
      };

      final address = GeoapifyService.formatAddress(props);
      expect(address, 'Librería América, Avenida Simón Bolívar, Miraflores');
    });

    test('strips trailing Bolivia from formatted fallback', () {
      final props = {
        'formatted': 'Zona Sur, Calacoto, La Paz, Bolivia',
      };

      final address = GeoapifyService.formatAddress(props);
      expect(address, 'Zona Sur, Calacoto, La Paz');
    });
  });

  group('GeoapifyService autocomplete tests', () {
    test('parses Geoapify autocomplete response correctly', () async {
      final mockResponse = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {
              'place_id': 'moscow_id_123',
              'formatted': 'Moscú, Rusia',
              'address_line1': 'Moscú',
              'address_line2': 'Rusia',
              'lat': 55.7505,
              'lon': 37.6175,
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['text'], 'Mosco');
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = GeoapifyService(client: mockClient);
      final results = await service.getAutocompletePredictions('Mosco');

      expect(results.length, 1);
      expect(results.first.mainText, 'Moscú');
      expect(results.first.secondaryText, 'Rusia');
      expect(results.first.description, 'Moscú, Rusia');
      expect(results.first.placeId, 'geoapify_moscow_id_123_55.7505_37.6175');
    });
  });

  group('Geoapify Places API v2 tests', () {
    test('fetches places by category and filter rectangle', () async {
      final mockResponse = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {
              'name': 'Aldi Süd',
              'country': 'Germany',
              'city': 'Donauwörth',
              'street': 'Kaiser-Karl-Straße',
              'housenumber': '4',
              'lon': 10.7560731,
              'lat': 48.7119723,
              'formatted':
                  'Aldi Süd, Kaiser-Karl-Straße 4, 86609 Donauwörth, Germany',
              'address_line1': 'Aldi Süd',
              'address_line2': 'Kaiser-Karl-Straße 4, 86609 Donauwörth, Germany',
              'categories': ['commercial', 'commercial.supermarket'],
              'place_id': 'aldi_id_123',
            },
            'geometry': {
              'type': 'Point',
              'coordinates': [10.75604, 48.71192],
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v2/places');
        expect(request.url.queryParameters['categories'],
            'commercial.supermarket');
        expect(request.url.queryParameters['filter'],
            'rect:10.716463143326969,48.755151258420966,10.835314015356737,48.680903341613316');
        expect(request.url.queryParameters['limit'], '20');
        expect(request.url.queryParameters['apiKey'], isNotEmpty);

        return http.Response(jsonEncode(mockResponse), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = GeoapifyService(client: mockClient);
      final places = await service.getPlaces(
        categories: 'commercial.supermarket',
        filter:
            'rect:10.716463143326969,48.755151258420966,10.835314015356737,48.680903341613316',
        limit: 20,
      );

      expect(places.length, 1);
      final place = places.first;
      expect(place.name, 'Aldi Süd');
      expect(place.city, 'Donauwörth');
      expect(place.street, 'Kaiser-Karl-Straße');
      expect(place.houseNumber, '4');
      expect(place.categories, contains('commercial.supermarket'));
      expect(place.latitude, closeTo(48.71197, 0.001));
      expect(place.longitude, closeTo(10.75607, 0.001));

      final prediction = place.toPrediction();
      expect(prediction.mainText, 'Aldi Süd');
      expect(prediction.placeId, contains('aldi_id_123'));
    });

    test('toShortAddress formats addresses concisely', () {
      expect(GeoapifyService.toShortAddress('Piedras 57, San Telmo, Buenos Aires, Argentina'), 'Piedras 57');
      expect(GeoapifyService.toShortAddress('Av. 16 de Julio 1525, La Paz, Bolivia'), 'Av. 16 de Julio 1525');
      expect(GeoapifyService.toShortAddress('Kaiser-Karl-Straße 4, 86609 Donauwörth, Germany'), 'Kaiser-Karl-Straße 4');
    });
  });
}

