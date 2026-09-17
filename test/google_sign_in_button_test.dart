import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Google sign-in button renders properly and switches text on mode change', (WidgetTester tester) async {
    // Render LoginScreen in a standard test viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pump();

    // Verify Google button exists in initial "Iniciar sesión" mode
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Switch to "Crear cuenta" mode
    final registerTabFinder = find.text('Crear cuenta');
    expect(registerTabFinder, findsOneWidget);
    await tester.tap(registerTabFinder);
    await tester.pumpAndSettle();

    // Verify Google button label updates to "Registrarse con Google"
    expect(find.text('Registrarse con Google'), findsOneWidget);
  });
}
