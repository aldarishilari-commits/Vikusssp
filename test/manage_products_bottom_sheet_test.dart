import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/core/services/business_service.dart';
import 'package:aeronpulse/features/profile/presentation/screens/management/manage_products_bottom_sheet.dart';

void main() {
  group('ManageProductsBottomSheet Widget Tests', () {
    testWidgets('Renders product list, opens form sheet, and opens camera/gallery modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final initialProducts = [
        const BusinessItemModel(
          id: 'prd-1',
          businessId: 'biz-123',
          itemType: 'product',
          name: 'Pizza Familiar',
          description: 'Masa artesanal y queso mozzarella',
          price: 65.0,
          imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
          availableQuantity: 15,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ManageProductsBottomSheet.show(
                    context,
                    businessId: 'biz-123',
                    businessName: 'Pizzería Vikus',
                    initialProducts: initialProducts,
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

      // Verify product sheet header and list items
      expect(find.text('Productos'), findsWidgets);
      expect(find.text('1 producto registrado'), findsOneWidget);
      expect(find.text('Pizza Familiar'), findsOneWidget);
      expect(find.text('Bs 65'), findsOneWidget);
      expect(find.text('Stock: 15'), findsOneWidget);

      // Tap "Agregar" button to open the product form sheet
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      // Verify form sheet is open
      expect(find.text('Nuevo Producto'), findsOneWidget);
      expect(find.text('Nombre del producto *'), findsOneWidget);
      expect(find.text('Precio (Bs) *'), findsOneWidget);
      expect(find.text('Stock disponible'), findsOneWidget);
      expect(find.text('Toca para agregar foto'), findsOneWidget);

      // Tap photo container to open the image source modal
      await tester.tap(find.text('Toca para agregar foto'));
      await tester.pumpAndSettle();

      // Verify the image source modal with Camera and Gallery options
      expect(find.text('Foto del producto'), findsWidgets);
      expect(find.text('Seleccionar de la galería'), findsOneWidget);
      expect(find.text('Elige una imagen de tu galería de fotos'), findsOneWidget);
      expect(find.text('Tomar foto con la cámara'), findsOneWidget);
      expect(find.text('Captura una foto ahora mismo'), findsOneWidget);
    });
  });
}
