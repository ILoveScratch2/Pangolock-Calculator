import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'calculator_mode.dart';

class SettingsManager {
  static const String _localeKey = 'locale';
  static const String _themeModeKey = 'theme_mode';
  static const String _calculationModeKey = 'calculation_mode';
  static const String _memoryKeysEnabledKey = 'memory_keys_enabled';

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Locale settings
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<Locale> getLocale() async {
    final prefs = await _prefs;
    final languageCode = prefs.getString(_localeKey) ?? 'en';
    return Locale(languageCode);
  }

  // Theme mode settings
  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, themeMode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // Calculation mode settings
  static Future<void> saveCalculationMode(CalculationMode calculationMode) async {
    final prefs = await _prefs;
    await prefs.setString(_calculationModeKey, calculationMode.name);
  }

  static Future<CalculationMode> getCalculationMode() async {
    final prefs = await _prefs;
    final calculationModeString = prefs.getString(_calculationModeKey) ?? 'classic';
    switch (calculationModeString) {
      case 'logic':
        return CalculationMode.logic;
      case 'classic':
      default:
        return CalculationMode.classic;
    }
  }

  // Memory keys enabled settings
  static Future<void> saveMemoryKeysEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_memoryKeysEnabledKey, enabled);
  }

  static Future<bool> getMemoryKeysEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_memoryKeysEnabledKey) ?? false;
  }

  // Load all settings at once
  static Future<Map<String, dynamic>> loadAllSettings() async {
    return {
      'locale': await getLocale(),
      'themeMode': await getThemeMode(),
      'calculationMode': await getCalculationMode(),
      'memoryKeysEnabled': await getMemoryKeysEnabled(),
    };
  }
}
