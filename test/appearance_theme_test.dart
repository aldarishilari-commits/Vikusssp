import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aeronpulse/core/services/theme_service.dart';
import 'package:aeronpulse/core/theme/app_theme.dart';
import 'package:aeronpulse/features/profile/presentation/screens/appearance_screen.dart';
import 'package:aeronpulse/features/profile/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeService.instance.setThemeMode(AppThemeMode.system);
  });

  group('ThemeService Unit Tests', () {
    test('Initial mode is system and maps to ThemeMode.system', () {
      expect(ThemeService.instance.currentThemeMode, AppThemeMode.system);
      expect(ThemeService.instance.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates state and notifies listeners', () async {
      int notifyCount = 0;
      ThemeService.instance.addListener(() {
        notifyCount++;
      });

      await ThemeService.instance.setThemeMode(AppThemeMode.dark);
      expect(ThemeService.instance.currentThemeMode, AppThemeMode.dark);
      expect(ThemeService.instance.themeMode, ThemeMode.dark);
      expect(notifyCount, greaterThan(0));

      await ThemeService.instance.setThemeMode(AppThemeMode.light);
      expect(ThemeService.instance.currentThemeMode, AppThemeMode.light);
      expect(ThemeService.instance.themeMode, ThemeMode.light);
    });

    test('initialize loads persisted preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      await ThemeService.instance.setThemeMode(AppThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    testWidgets('AppTheme provides both lightTheme and darkTheme with proper brightness', (tester) async {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });
  });

  group('AppearanceScreen Widget Tests', () {
    Widget buildTestApp() {
      return AnimatedBuilder(
        animation: ThemeService.instance,
        builder: (context, _) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeService.instance.themeMode,
            home: const AppearanceScreen(),
          );
        },
      );
    }

    testWidgets('AppearanceScreen renders all options and live preview', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Apariencia'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(find.text('Vista previa en tiempo real'), findsOneWidget);
      expect(find.text('Vikus Marketplace'), findsOneWidget);
    });

    testWidgets('Tapping "Oscuro" updates ThemeService to dark and shows SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap dark option
      final darkOptionFinder = find.byKey(const Key('theme_option_dark'));
      expect(darkOptionFinder, findsOneWidget);
      await tester.tap(darkOptionFinder);
      await tester.pumpAndSettle();

      expect(ThemeService.instance.currentThemeMode, AppThemeMode.dark);
      expect(find.text('Tema Oscuro activado'), findsOneWidget);
      expect(find.text('Modo actual: Oscuro'), findsOneWidget);

      // Verify preference was persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    testWidgets('Tapping "Claro" updates ThemeService to light and shows SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap light option
      final lightOptionFinder = find.byKey(const Key('theme_option_light'));
      expect(lightOptionFinder, findsOneWidget);
      await tester.tap(lightOptionFinder);
      await tester.pumpAndSettle();

      expect(ThemeService.instance.currentThemeMode, AppThemeMode.light);
      expect(find.text('Tema Claro activado'), findsOneWidget);
      expect(find.text('Modo actual: Claro'), findsOneWidget);
    });
  });

  group('SettingsScreen Appearance Integration Tests', () {
    testWidgets('SettingsScreen displays active theme label dynamically', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await ThemeService.instance.setThemeMode(AppThemeMode.system);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apariencia'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);

      // Switch theme to dark
      await ThemeService.instance.setThemeMode(AppThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Oscuro'), findsOneWidget);
    });
  });
}
