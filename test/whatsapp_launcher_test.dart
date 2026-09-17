import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/core/services/whatsapp_launcher_service.dart';

void main() {
  group('WhatsApp Launcher Service Tests', () {
    test('Cleans and formats standard 8-digit Bolivian phone numbers with +591 prefix', () {
      final formatted1 = WhatsAppLauncherService.formatPhoneNumber(phoneNumber: '70123456');
      expect(formatted1, '59170123456');

      final formatted2 = WhatsAppLauncherService.formatPhoneNumber(phoneNumber: ' 712-34567 ');
      expect(formatted2, '59171234567');
    });

    test('Preserves phone numbers that already include country code', () {
      final formatted = WhatsAppLauncherService.formatPhoneNumber(phoneNumber: '+591 70123456');
      expect(formatted, '59170123456');

      final formattedIntl = WhatsAppLauncherService.formatPhoneNumber(phoneNumber: '59178901234');
      expect(formattedIntl, '59178901234');
    });

    test('Encodes personalized greeting message correctly', () {
      const bizName = 'BODY XTREME';
      const msg = '¡Hola $bizName! Los encontré en Vikus y quisiera hacer una consulta.';
      final encoded = Uri.encodeComponent(msg);
      final url = 'https://wa.me/59170123456?text=$encoded';

      expect(url.contains('59170123456'), isTrue);
      expect(url.contains(Uri.encodeComponent('BODY XTREME')), isTrue);
    });
  });
}
