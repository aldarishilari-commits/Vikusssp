import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/business/domain/models/business_registration_model.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/steps/step8_photo_screen.dart';

void main() {
  group('Step8PhotoScreen Widget Tests', () {
    testWidgets('Renders empty state with photo upload box and buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final data = BusinessRegistrationData();
      bool exitCalled = false;
      bool backCalled = false;
      bool nextCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Step8PhotoScreen(
              data: data,
              onExit: () => exitCalled = true,
              onBack: () => backCalled = true,
              onNext: () => nextCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & buttons
      expect(find.text('¿Quieres agregar fotos de tu\nnegocio?'), findsOneWidget);
      expect(find.text('Guardar y salir'), findsOneWidget);
      expect(find.text('Atrás'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.text('Toca para agregar fotos'), findsOneWidget);

      // Tap "Atrás"
      await tester.tap(find.text('Atrás'));
      expect(backCalled, isTrue);

      // Tap "Siguiente"
      await tester.tap(find.text('Siguiente'));
      expect(nextCalled, isTrue);

      // Tap "Guardar y salir"
      await tester.tap(find.text('Guardar y salir'));
      expect(exitCalled, isTrue);
    });

    testWidgets('Renders photo preview and delete badge when photo exists',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final data = BusinessRegistrationData(
        photoUrls: [
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80',
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Step8PhotoScreen(
              data: data,
              onExit: () {},
              onBack: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify "Portada principal" badge
      expect(find.text('Portada principal'), findsOneWidget);
      expect(find.text('Fotos agregadas (1)'), findsOneWidget);
      expect(find.text('+ Agregar más'), findsOneWidget);
    });
  });
}
