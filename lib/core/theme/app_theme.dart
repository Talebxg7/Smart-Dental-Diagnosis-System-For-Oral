import 'package:flutter/material.dart';

/// App version (match pubspec version)
const String appVersion = '1.0.0';

/// Darker green (Turkish/Egypt style)
const Color appPrimaryGreen = Color(0xFF047857);
const Color appPrimaryGreenDark = Color(0xFF065F46);

/// Light mint for login/register backgrounds
const Color appLightMint = Color(0xFFE8F5F2);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: appLightMint,
  colorScheme: ColorScheme.fromSeed(
    seedColor: appPrimaryGreen,
    brightness: Brightness.light,
    primary: appPrimaryGreen,
    secondary: appPrimaryGreenDark,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: appPrimaryGreen,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: appPrimaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade50,
  ),
);

/// Dark theme
final ThemeData appThemeDark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: appPrimaryGreen,
    brightness: Brightness.dark,
    primary: appPrimaryGreen,
    secondary: appPrimaryGreenDark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: appPrimaryGreenDark,
    foregroundColor: Colors.white,
  ),
  cardColor: const Color(0xFF1E1E1E),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: appPrimaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade800,
  ),
);
