import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aeronpulse/core/services/google_places_service.dart';

void main() {
  group('GooglePlacesService Tests', () {
    test('returns predictions from Google Places Autocomplete API', () async {
      final mockGoogleResponse = {
        'status': 'OK',
        'predictions': [
          {
            'place_id': 'ChIJvx3k8GIgX5ERyR5Y3muIrnM',
            'description': 'Sopocachi, La Paz, Bolivia',
            'structured_formatting': {
              'main_text': 'Sopocachi',
              'secondary_text': 'La Paz, Bolivia',
            },
          },
          {
            'place_id': 'ChIJ_abc123',
            'description': 'Calacoto, La Paz, Bolivia',
            'structured_formatting': {
              'main_text': 'Calacoto',
              'secondary_text': 'La Paz, Bolivia',
            },
          }
        ]
      };

      final mockClient = MockClient((request) async {
        if (request.url.host == 'maps.googleapis.com' &&
            request.url.path == '/maps/api/place/autocomplete/json') {
          return http.Response(
            jsonEncode(mockGoogleResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = GooglePlacesService(client: mockClient);
      final results = await service.getAutocompletePredictions('Sopocachi');

      expect(results.length, 2);
      expect(results[0].placeId, 'ChIJvx3k8GIgX5ERyR5Y3muIrnM');
      expect(results[0].mainText, 'Sopocachi');
      expect(results[0].secondaryText, 'La Paz, Bolivia');
      expect(results[0].description, 'Sopocachi, La Paz, Bolivia');
      expect(results[1].mainText, 'Calacoto');
    });

    test('retrieves place details and cleans Plus Codes', () async {
      final mockDetailsResponse = {
        'status': 'OK',
        'result': {
          'name': 'Calacoto Center',
          'formatted_address': 'FW56+HM7, Av. Sanchez Bustamante, La Paz, Bolivia',
          'address_components': [
            {'long_name': 'Calacoto', 'types': ['neighborhood']},
            {'long_name': 'La Paz', 'types': ['locality']},
          ],
          'geometry': {
            'location': {
              'lat': -16.5410,
              'lng': -68.0883,
            }
          }
        }
      };

      final mockClient = MockClient((request) async {
        if (request.url.host == 'maps.googleapis.com' &&
            request.url.path == '/maps/api/place/details/json') {
          return http.Response(
            jsonEncode(mockDetailsResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = GooglePlacesService(client: mockClient);
      final details =
          await service.getPlaceDetails('ChIJv1fo7SUhX5ERqUQTBPtz5B4');

      expect(details, isNotNull);
      // Confirma que el Plus Code fue removido y el barrio integrado
      expect(details!.address, 'Av. Sanchez Bustamante, Calacoto, La Paz');
      expect(details.latitude, -16.5410);
      expect(details.longitude, -68.0883);
    });

    test('cleanAddress removes Plus Codes and duplicate country suffix', () {
      expect(
        GooglePlacesService.cleanAddress('FW58+P43, Av. Arce 123, La Paz, Bolivia'),
        'Av. Arce 123, La Paz',
      );
      expect(
        GooglePlacesService.cleanAddress('FVPC+XV La Paz, Bolivia'),
        'La Paz',
      );
    });

    test('toShortAddress extracts concise street and number format', () {
      expect(
        GooglePlacesService.toShortAddress('Piedras 57, Ciudad Autónoma de Buenos Aires, Argentina'),
        'Piedras 57',
      );
      expect(
        GooglePlacesService.toShortAddress('Av. Belgrano 300, Cdad. Autónoma de Buenos Aires, Argentina'),
        'Av. Belgrano 300',
      );
      expect(
        GooglePlacesService.toShortAddress('Av. Corrientes 59, Ciudad Autónoma de Buenos Aires, Argentina'),
        'Av. Corrientes 59',
      );
      expect(
        GooglePlacesService.toShortAddress('Av. 16 de Julio 1525, Universidad, La Paz, Bolivia'),
        'Av. 16 de Julio 1525',
      );
    });

    test('extractExactAddressFromGoogle selects street_address over beauty salon and plus code', () {
      final results = [
        {
          'types': ['beauty_salon', 'establishment', 'point_of_interest'],
          'formatted_address': 'Of. 3, Edificio 16 de Julio, La Paz, Bolivia',
          'address_components': [
            {'long_name': 'Centro', 'types': ['neighborhood']},
            {'long_name': 'La Paz', 'types': ['locality']},
          ]
        },
        {
          'types': ['plus_code'],
          'formatted_address': 'FVX8+CV La Paz, Bolivia',
          'address_components': [
            {'long_name': 'La Paz', 'types': ['locality']},
          ]
        },
        {
          'types': ['street_address', 'subpremise'],
          'formatted_address': 'Av. 16 de Julio 1525, La Paz, Bolivia',
          'address_components': [
            {'long_name': 'Av. 16 de Julio', 'types': ['route']},
            {'long_name': '1525', 'types': ['street_number']},
            {'long_name': 'Centro', 'types': ['neighborhood']},
            {'long_name': 'La Paz', 'types': ['locality']},
          ]
        },
      ];

      final exact = GooglePlacesService.extractExactAddressFromGoogle(results);
      expect(exact, 'Av. 16 de Julio 1525, Centro, La Paz');
    });

    test('falls back to Geoapify if Google returns ZERO_RESULTS', () async {
      final mockGoogleZeroResponse = {
        'status': 'ZERO_RESULTS',
        'predictions': [],
      };

      final mockGeoapifyResponse = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {
              'place_id': 'geoapify_unique_place_1',
              'formatted': 'Calle Sagarnaga 123, Rosario, La Paz',
              'address_line1': 'Calle Sagarnaga 123',
              'address_line2': 'Rosario, La Paz',
              'lat': -16.4975,
              'lon': -68.1380,
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        if (request.url.host == 'maps.googleapis.com') {
          return http.Response(jsonEncode(mockGoogleZeroResponse), 200);
        }
        if (request.url.host == 'api.geoapify.com') {
          return http.Response(
            jsonEncode(mockGeoapifyResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = GooglePlacesService(client: mockClient);
      final results = await service.getAutocompletePredictions('Sagarnaga');

      expect(results.length, 1);
      expect(results.first.mainText, 'Calle Sagarnaga 123');
      expect(results.first.secondaryText, 'Rosario, La Paz');
      expect(results.first.placeId, startsWith('geoapify_'));
    });
  });
}
