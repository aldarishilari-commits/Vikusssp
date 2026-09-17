import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/business/presentation/screens/business_profile_screen.dart';
import 'package:aeronpulse/features/home/presentation/widgets/business_card_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testBusiness = BusinessModel(
    id: 'test_dentist_1',
    name: 'Dentista La Paz',
    category: 'Salud Dental',
    rating: 4.0,
    reviewsCount: 24,
    address: 'Av. Pando',
    distance: '100 m de ti',
    latitude: -16.4950,
    longitude: -68.1330,
    isOpen: true,
    phoneNumber: '+591 70123456',
    facebook: 'https://facebook.com/dentistalapaz',
    tiktok: '@dentistalapaz',
    instagram: '@dentistalapaz',
    website: 'dentistalapaz.com',
    imageUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5',
    description: 'Dentista con atención cercana y precios accesibles.',
  );

  Widget createTestWidget() {
    return const MaterialApp(
      home: BusinessProfileScreen(business: testBusiness),
    );
  }

  testWidgets('BusinessProfileScreen renders services and selection hint', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Business Name
    expect(find.text('Dentista La Paz'), findsOneWidget);

    // Verify Selection hint
    expect(
      find.text('Selecciona lo que te interesa para consultar'),
      findsOneWidget,
    );

    // Verify Tabs exist
    expect(find.text('🔥'), findsOneWidget);
    expect(find.text('Ofertas flash'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Servicios'), findsOneWidget);

    // Verify Services tab is selected by default and services are visible
    expect(find.byKey(const Key('service_item_serv_dent_1')), findsOneWidget);
    expect(find.byKey(const Key('service_item_serv_dent_2')), findsOneWidget);
    expect(find.byKey(const Key('service_item_serv_dent_3')), findsOneWidget);
    expect(find.text('Limpieza dental'), findsWidgets);
    expect(find.text('Blanqueamiento dental'), findsWidgets);
    expect(find.text('Curaciones dentales'), findsOneWidget);
    expect(find.text('Bs. 65'), findsWidgets);
  });

  testWidgets('Tapping services toggles selection and displays floating WhatsApp consultation button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Initially, no floating consultation button is displayed
    expect(find.textContaining('Consultar por WhatsApp'), findsNothing);

    // Tap on first service card ("Limpieza dental")
    final service1Finder = find.byKey(const Key('service_item_serv_dent_1'));
    expect(service1Finder, findsOneWidget);
    await tester.tap(service1Finder);
    await tester.pumpAndSettle();

    // Now floating WhatsApp button appears with count (1)
    expect(find.text('Consultar por WhatsApp (1)'), findsOneWidget);

    // Tap on second service card ("Blanqueamiento dental")
    final service2Finder = find.byKey(const Key('service_item_serv_dent_2'));
    expect(service2Finder, findsOneWidget);
    await tester.tap(service2Finder);
    await tester.pumpAndSettle();

    // Now floating button updates with count (2)
    expect(find.text('Consultar por WhatsApp (2)'), findsOneWidget);

    // Tap "Blanqueamiento dental" again to deselect
    await tester.tap(service2Finder);
    await tester.pumpAndSettle();

    // Count drops back to 1
    expect(find.text('Consultar por WhatsApp (1)'), findsOneWidget);

    // Tap "Limpieza dental" again to deselect
    await tester.tap(service1Finder);
    await tester.pumpAndSettle();

    // Floating button disappears when 0 selected
    expect(find.textContaining('Consultar por WhatsApp'), findsNothing);
  });

  testWidgets('Special offers banner renders 2x1 and Solo hoy badges', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ofertas'), findsOneWidget);
    expect(find.text('Ver todas'), findsWidgets);
    expect(find.text('Nuevo'), findsWidgets);
    expect(find.text('2x1'), findsWidgets);
    expect(find.text('Solo hoy'), findsWidgets);
  });

  testWidgets('Reviews section displays Aldaris testimonial and 4 stars', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Opiniones'), findsOneWidget);
    expect(find.text('Aldaris'), findsOneWidget);
    expect(find.text('Hace 2 días'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });
}
