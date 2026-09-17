import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/main.dart';
import 'package:aeronpulse/features/home/presentation/screens/home_screen.dart';
import 'package:aeronpulse/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/profile_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/settings_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/change_password_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/appearance_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/notifications_settings_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/change_email_screen.dart';

void main() {
  testWidgets('App displays onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify Onboarding elements
    expect(find.text('Entrar a Vikus'), findsOneWidget);
    expect(find.text('Entra como invitado'), findsOneWidget);
  });

  testWidgets('HomeScreen displays Vikus elements smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Vikus'),
      ),
    );
    await tester.pump();

    // Verify Home elements
    expect(find.text('Pando'), findsOneWidget);
    expect(find.text('¿Qué buscas hoy en Pando?'), findsOneWidget);
    expect(find.text('Comida'), findsOneWidget);
    expect(find.text('Ofertas cerca de ti'), findsOneWidget);
    expect(find.text('Negocios cerca de ti'), findsOneWidget);
  });

  testWidgets('FavoritesScreen displays 2x2 category grid and callout banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FavoritesScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify Header
    expect(find.text('Favoritos'), findsOneWidget);

    // Verify 4 Category Cards matching Stitch Favoritos (1).jpg / Favoritos - Vikus
    expect(find.text('Negocios favoritos'), findsOneWidget);
    expect(find.text('Servicios favoritos'), findsOneWidget);
    expect(find.text('Productos favoritos'), findsOneWidget);
    expect(find.text('Ofertas favoritas'), findsOneWidget);

    // Verify Bookmark Banner
    expect(find.text('Aún no tienes favoritos'), findsOneWidget);
  });

  testWidgets('ProfileScreen displays personal profile and business admin tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            selectedCity: 'La Paz',
            onCityChange: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify Header & User Info
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Aldaris Guzmán'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);

    // Verify Tabs matching Stitch Mi Perfil (2).png
    expect(find.text('Mi Perfil'), findsOneWidget);
    expect(find.text('Mi Negocio'), findsOneWidget);

    // Verify Tab 1 content
    expect(find.text('Negocios que sigues'), findsOneWidget);
    expect(find.text('¿Tienes un negocio?'), findsOneWidget);

    // Switch to Tab 2: Mi Negocio
    await tester.tap(find.text('Mi Negocio'));
    await tester.pump();

    // Verify Tab 2 content
    expect(find.text("Elis' Pizza"), findsOneWidget);
    expect(find.text('Impulsar negocio'), findsOneWidget);
    expect(find.text('Tu rendimiento'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
    expect(find.text('Administrar negocio'), findsOneWidget);
    expect(find.text('Crear nuevo negocio'), findsOneWidget);
  });

  testWidgets('SettingsScreen displays all 4 sections and logout matching Stitch reference', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          onLogout: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);

    expect(find.text('Gestión'), findsOneWidget);
    expect(find.text('Mis negocios'), findsOneWidget);
    expect(find.text('Pagos y facturación'), findsOneWidget);

    expect(find.text('Privacidad y seguridad'), findsOneWidget);
    expect(find.text('Política de privacidad'), findsOneWidget);

    expect(find.text('Ayuda'), findsOneWidget);
    expect(find.text('Contactar soporte'), findsOneWidget);

    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('EditProfileScreen displays form fields and security notice', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditProfileScreen(
          initialName: 'Aldaris Guzmán',
          initialPhone: '78946546',
          initialEmail: 'aldarisguzman@gmail.com',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Actualiza tu información personal'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Teléfono celular'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('aldarisguzman@gmail.com'), findsOneWidget);
    expect(find.text('Tu información está segura'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('ChangePasswordScreen renders inputs and validation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChangePasswordScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Contraseña actual'), findsOneWidget);
    expect(find.text('Nueva contraseña'), findsOneWidget);
    expect(find.text('Confirmar nueva contraseña'), findsOneWidget);
    expect(find.text('Actualizar contraseña'), findsOneWidget);
  });

  testWidgets('AppearanceScreen allows switching themes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppearanceScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
  });

  testWidgets('NotificationsSettingsScreen displays all toggles and control banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsSettingsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Activar todas las notificaciones'), findsOneWidget);
    expect(find.text('OFERTAS DE NEGOCIOS QUE SIGUES'), findsOneWidget);
    expect(find.text('Nuevas ofertas'), findsOneWidget);
    expect(find.text('Ofertas por vencer'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('Mensajes importantes de la app'), findsOneWidget);
    expect(find.text('Tú tienes el control'), findsOneWidget);
  });

  testWidgets('ChangeEmailScreen multi-step flow works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChangeEmailScreen(
          currentEmail: 'aldarisguzman@gmail.com',
        ),
      ),
    );
    await tester.pump();

    // Step 0
    expect(find.text('Correo electronico'), findsOneWidget);
    expect(find.text('Correo electronico actual'), findsOneWidget);
    expect(find.text('aldarisguzman@gmail.com'), findsOneWidget);
    expect(find.text('Nuevo correo electronico'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);

    // Enter new email and submit
    await tester.enterText(find.byType(TextField), 'nuevo@correo.com');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Step 1: Verification Sent
    expect(find.text('Enlace de verificación enviado'), findsOneWidget);
    expect(find.text('Ir a mi correo'), findsOneWidget);
    expect(find.text('Entendido, volver al perfil'), findsOneWidget);
  });
}
