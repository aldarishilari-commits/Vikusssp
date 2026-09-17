import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modos de apariencia soportados por la aplicación
enum AppThemeMode {
  system,
  light,
  dark;

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'Sistema';
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.system:
        return 'Se ajusta automáticamente según la configuración de tu dispositivo.';
      case AppThemeMode.light:
        return 'Interfaz clara y luminosa para el día a día.';
      case AppThemeMode.dark:
        return 'Interfaz oscura elegante que descansa tu vista y ahorra batería.';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.wb_sunny_rounded;
      case AppThemeMode.dark:
        return Icons.nightlight_round_rounded;
    }
  }
}

/// Servicio singleton para gestionar y persistir el tema de la aplicación
class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _prefKey = 'app_theme_mode';
  AppThemeMode _currentMode = AppThemeMode.system;
  bool _isInitialized = false;

  AppThemeMode get currentThemeMode => _currentMode;
  bool get isInitialized => _isInitialized;

  /// Convierte el modo de la app a ThemeMode nativo de Flutter
  ThemeMode get themeMode {
    switch (_currentMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Verifica si el modo actual es oscuro considerando el contexto del sistema
  bool isDarkMode(BuildContext context) {
    if (_currentMode == AppThemeMode.dark) return true;
    if (_currentMode == AppThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  /// Inicializa el servicio leyendo la preferencia guardada
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode != null) {
        _currentMode = AppThemeMode.values.firstWhere(
          (e) => e.name == savedMode,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error al cargar la preferencia de tema: $e');
      _currentMode = AppThemeMode.system;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Cambia el modo de tema y lo persiste en SharedPreferences
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentMode == mode) return;

    _currentMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (e) {
      debugPrint('Error al guardar la preferencia de tema: $e');
    }
  }
}
