import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeDarkKey = 'app_theme_dark';
const _kLanguageKey = 'app_language_code';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeModeNotifier() {
    _load();
  }

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dark = prefs.getBool(_kThemeDarkKey) ?? false;
      final code = prefs.getString(_kLanguageKey) ?? 'en';
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      _locale = Locale(code);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(bool dark) async {
    if (_themeMode == (dark ? ThemeMode.dark : ThemeMode.light)) return;
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kThemeDarkKey, dark);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, locale.languageCode);
    } catch (_) {}
    notifyListeners();
  }
}
