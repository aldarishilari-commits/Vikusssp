import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/business/presentation/screens/business_profile_screen.dart';
import 'package:aeronpulse/features/home/presentation/widgets/business_card_item.dart';

void main() {
  testWidgets('BusinessProfileScreen cover carousel swipes, updates pagination dots and count badge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const testBusiness = BusinessModel(
      id: 'biz_carousel_test',
      name: 'Pizzería Napolitana',
      category: 'Comida',
      description: 'Pizzas al horno de leña.',
      address: 'Calle 21 de Calacoto',
      distance: '150 m',
      imageUrl: 'https://example.com/cover1.jpg',
      photoUrls: [
        'https://example.com/cover1.jpg',
        'https://example.com/cover2.jpg',
        'https://example.com/cover3.jpg',
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessProfileScreen(business: testBusiness),
      ),
    );

    // Initial page should be 1/3
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    // Swipe left on the PageView to navigate to the second photo
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Now page should be 2/3
    expect(find.text('2/3'), findsOneWidget);

    // Swipe left again to navigate to the third photo
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Now page should be 3/3
    expect(find.text('3/3'), findsOneWidget);

    // Swipe right to go back to second photo
    await tester.drag(find.byType(PageView), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(find.text('2/3'), findsOneWidget);
  });
}
