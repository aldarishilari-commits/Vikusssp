import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/business/presentation/screens/business_profile_screen.dart';
import 'package:aeronpulse/features/home/presentation/widgets/business_card_item.dart';

void main() {
  testWidgets('BusinessProfileScreen renders all 4 social media buttons and they are interactive', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const testBusiness = BusinessModel(
      id: 'biz_social_test',
      name: 'Gym Test Pro',
      category: 'Deporte',
      description: 'Gimnasio con máquinas modernas y entrenadores.',
      address: 'Av. Pando #123',
      distance: '200 m',
      imageUrl: 'https://example.com/image.jpg',
      facebook: 'https://facebook.com/gymtestpro',
      instagram: 'gymtestpro.bo',
      tiktok: 'gymtestpro',
      website: 'https://gymtestpro.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessProfileScreen(business: testBusiness),
      ),
    );

    // Scroll until social buttons are visible
    final mainScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byTooltip('Facebook'),
      300,
      scrollable: mainScrollable,
    );
    await tester.pumpAndSettle();

    // Verify all 4 social button tooltips / icons exist in the widget tree
    expect(find.byTooltip('Facebook'), findsOneWidget);
    expect(find.byTooltip('TikTok'), findsOneWidget);
    expect(find.byTooltip('Instagram'), findsOneWidget);
    expect(find.byTooltip('Página Web'), findsOneWidget);

    // Verify icons inside the buttons
    expect(find.byIcon(Icons.facebook), findsOneWidget);
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsWidgets);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);

    // Tap on Facebook button
    await tester.tap(find.byTooltip('Facebook'));
    await tester.pump();

    // Tap on TikTok button
    await tester.tap(find.byTooltip('TikTok'));
    await tester.pump();

    // Tap on Instagram button
    await tester.tap(find.byTooltip('Instagram'));
    await tester.pump();

    // Tap on Web button
    await tester.tap(find.byTooltip('Página Web'));
    await tester.pump();
  });

  testWidgets('BusinessProfileScreen shows friendly SnackBar when business has empty social links', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const emptySocialBusiness = BusinessModel(
      id: 'biz_empty_social',
      name: 'Negocio Sin Redes',
      category: 'Comida',
      description: 'Restaurante tradicional sin redes registradas.',
      address: 'Calle 1 #45',
      distance: '500 m',
      imageUrl: 'https://example.com/image2.jpg',
      facebook: '',
      instagram: '',
      tiktok: '',
      website: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessProfileScreen(business: emptySocialBusiness),
      ),
    );

    // Scroll down to social buttons
    final mainScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byTooltip('TikTok'),
      300,
      scrollable: mainScrollable,
    );
    await tester.pumpAndSettle();

    // Tap TikTok button
    await tester.tap(find.byTooltip('TikTok'));
    await tester.pump();

    // Verify feedback SnackBar was shown
    expect(
      find.text('"Negocio Sin Redes" aún no tiene un enlace de TikTok registrado.'),
      findsOneWidget,
    );
  });
}
