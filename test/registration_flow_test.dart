import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/features/business/presentation/screens/registration/business_registration_flow_screen.dart';

void main() {
  testWidgets('BusinessRegistrationFlowScreen full 11-step flow test',
      (WidgetTester tester) async {
    // Set a modern mobile phone viewport size for realistic testing
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessRegistrationFlowScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 1: Inicio del registro ("Inicio del registro-1.png")
    // -------------------------------------------------------------
    expect(find.text('Consigue más clientes\ncerca de ti'), findsOneWidget);
    expect(find.text('Muestra tus productos, servicios y ofertas'), findsOneWidget);
    expect(find.text('Haz visible tu negocio'), findsOneWidget);
    expect(find.text('Conecta con clientes por WhatsApp\ny redes'), findsOneWidget);
    expect(find.text('Muestra lo que ofreces'), findsOneWidget);
    expect(find.text('Aumenta tus ventas con ofertas'), findsOneWidget);
    expect(find.text('Registrar mi negocio'), findsOneWidget);

    // Tap "Registrar mi negocio" -> moves to Screen 2
    await tester.tap(find.text('Registrar mi negocio'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 2: Nombre del negocio ("Registro del negocio_nombre-2.png")
    // -------------------------------------------------------------
    expect(find.text('¿Cómo se llama tu negocio?'), findsOneWidget);
    expect(find.text('Este nombre será visible para tus clientes.'), findsOneWidget);
    expect(find.text('Nombre del negocio'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);

    // Enter name & description
    await tester.enterText(find.byType(TextField).first, 'Café Tuna');
    await tester.enterText(find.byType(TextField).last, 'Cafetería especializada');
    await tester.pumpAndSettle();

    // Tap "Continuar" -> moves to Screen 3
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 3: Categoría ("Registro_negocio_categoria-3.png")
    // -------------------------------------------------------------
    expect(find.text('Selecciona la categoria de\ntu negocio'), findsOneWidget);
    expect(find.text('Restaurantes y\ncomida'), findsOneWidget);
    expect(find.text('Cafeterias y\nbebidas'), findsOneWidget);
    expect(find.text('Educación'), findsOneWidget);
    expect(find.text('Belleza y salud'), findsOneWidget);
    expect(find.text('Ropa y moda'), findsOneWidget);
    expect(find.text('Deportes y ocio'), findsOneWidget);

    // Select "Cafeterias y bebidas"
    await tester.tap(find.text('Cafeterias y\nbebidas'));
    await tester.pumpAndSettle();

    // Tap "Siguiente" -> moves to Screen 4
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 4: Ubicación ("Registro del negocio_ubicación-4.png")
    // -------------------------------------------------------------
    expect(find.text('¿Donde está tu negocio?'), findsOneWidget);
    expect(find.text('Usar mi ubicación actual'), findsOneWidget);

    // Tap "Siguiente" -> moves to Screen 5
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 5: Ubicación confirmada ("Registro del negocio_ubicación_despues-5.png")
    // -------------------------------------------------------------
    expect(find.text('¿Donde está tu negocio?'), findsOneWidget);
    expect(find.text('Av. Pando, La Paz'), findsOneWidget);

    // Tap "Siguiente" -> moves to Screen 6
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 6: Contacto ("Registro del negocio_contacto-6.png")
    // -------------------------------------------------------------
    expect(find.text('¿Como te pueden contactar\nlos clientes?'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('+591'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Página web'), findsOneWidget);

    // Enter phone
    await tester.enterText(find.byType(TextField).first, '78912345');
    await tester.pumpAndSettle();

    // Tap "Siguiente" -> moves to Screen 7
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 7: Horario ("Registro del negocio_horario-7.png")
    // -------------------------------------------------------------
    expect(find.text('Horario de atención'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Martes'), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);

    // Tap "Siguiente" -> moves to Screen 8
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 8: Foto ("Registro del negocio_foto-8.png")
    // -------------------------------------------------------------
    expect(find.text('¿Quieres agregar fotos de tu\nnegocio?'), findsOneWidget);

    // Tap "Siguiente" -> moves to Screen 9
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 9: Información del negocio ("Registro del negocio_9.png")
    // -------------------------------------------------------------
    expect(find.text('Agrega servicios'), findsOneWidget);
    expect(find.text('Agrega productos'), findsOneWidget);
    expect(find.text('¡Listo!'), findsOneWidget);
    expect(find.text('Tu negocio ya está\nlisto para publicar'), findsOneWidget);
    expect(find.text('Terminar'), findsOneWidget);

    // -------------------------------------------------------------
    // Screen 10: Navegar a Productos ("Registro del negocio_producto-10.png")
    // -------------------------------------------------------------
    await tester.tap(find.text('Agrega productos'));
    await tester.pumpAndSettle();

    expect(find.text('Producto'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Precio normal'), findsOneWidget);
    expect(find.text('Tipo de Oferta'), findsOneWidget);
    expect(find.text('Sin oferta'), findsOneWidget);
    expect(find.text('Oferta flash'), findsOneWidget);
    expect(find.text('Agregar producto'), findsOneWidget);

    // Fill and add product
    await tester.enterText(find.byType(TextField).first, 'Hamburguesa Clásica');
    await tester.tap(find.text('Agregar producto'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Back in Screen 9 with product badge
    expect(find.text('¡Listo!'), findsOneWidget);

    // -------------------------------------------------------------
    // Screen 11: Navegar a Servicios ("Registro del negocio_servicio-11.png")
    // -------------------------------------------------------------
    await tester.tap(find.text('Agrega servicios'));
    await tester.pumpAndSettle();

    expect(find.text('Servicio'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Precio normal'), findsOneWidget);
    expect(find.text('Tipo de Oferta'), findsOneWidget);
    expect(find.text('Agregar servicio'), findsOneWidget);

    // Fill and add service
    await tester.enterText(find.byType(TextField).first, 'Limpieza Dental');
    await tester.tap(find.text('Agregar servicio'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Back in Screen 9
    expect(find.text('¡Listo!'), findsOneWidget);

    // Test back navigation preserving data:
    // Tap "Atrás" to go to Screen 8
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('¿Quieres agregar fotos de tu\nnegocio?'), findsOneWidget);

    // Tap "Atrás" to go to Screen 7
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('Horario de atención'), findsOneWidget);

    // Tap "Atrás" to go to Screen 6
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('¿Como te pueden contactar\nlos clientes?'), findsOneWidget);
    expect(find.text('78912345'), findsOneWidget); // Data retained!

    // Tap "Atrás" to go to Screen 5
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('¿Donde está tu negocio?'), findsOneWidget);
    expect(find.text('Av. Pando, La Paz'), findsOneWidget); // Data retained!

    // Tap "Atrás" to go to Screen 4
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('¿Donde está tu negocio?'), findsOneWidget);

    // Tap "Atrás" to go to Screen 3
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona la categoria de\ntu negocio'), findsOneWidget);

    // Tap "Atrás" to go to Screen 2
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('Café Tuna'), findsOneWidget); // Data retained!
  });
}
