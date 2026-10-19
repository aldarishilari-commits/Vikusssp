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
}
