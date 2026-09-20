import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/core/services/business_service.dart';
import 'package:aeronpulse/features/profile/presentation/screens/management/manage_services_bottom_sheet.dart';

void main() {
  group('ManageServicesBottomSheet Widget Tests', () {
    testWidgets('Renders service list, opens form sheet, and opens camera/gallery modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final initialServices = [
        const BusinessItemModel(
          id: 'srv-1',
          businessId: 'biz-123',
          itemType: 'service',
          name: 'Corte Clásico',
          description: 'Corte de cabello para caballeros',
          price: 45.0,
          imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ManageServicesBottomSheet.show(
                    context,
                    businessId: 'biz-123',
                    businessName: 'Barbería Vikus',
                    initialServices: initialServices,
                    onUpdated: () {},
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      // Open the sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify service sheet header and list items
      expect(find.text('Servicios'), findsWidgets);
      expect(find.text('1 servicio registrado'), findsOneWidget);
      expect(find.text('Corte Clásico'), findsOneWidget);
      expect(find.text('Bs 45'), findsOneWidget);

      // Tap "Agregar" button to open the service form sheet
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      // Verify form sheet is open
      expect(find.text('Nuevo Servicio'), findsOneWidget);
      expect(find.text('Nombre del servicio *'), findsOneWidget);
      expect(find.text('Precio desde (Bs) *'), findsOneWidget);
      expect(find.text('Toca para agregar foto'), findsOneWidget);

      // Tap photo container to open the image source modal
      await tester.tap(find.text('Toca para agregar foto'));
      await tester.pumpAndSettle();

      // Verify the image source modal with Camera and Gallery options
      expect(find.text('Foto del servicio'), findsWidgets);
      expect(find.text('Seleccionar de la galería'), findsOneWidget);
      expect(find.text('Elige una imagen de tu galería de fotos'), findsOneWidget);
      expect(find.text('Tomar foto con la cámara'), findsOneWidget);
      expect(find.text('Captura una foto ahora mismo'), findsOneWidget);
    });
  });
}
