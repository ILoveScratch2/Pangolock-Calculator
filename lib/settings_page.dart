import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'calculator_mode.dart';

class SettingsPage extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  final Function(ThemeMode) onThemeModeChange;
  final Function(CalculationMode) onCalculationModeChange;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final CalculationMode currentCalculationMode;

  const SettingsPage({
    super.key,
    required this.onLocaleChange,
    required this.onThemeModeChange,
    required this.onCalculationModeChange,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.currentCalculationMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Calculation Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.calculationMode,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<CalculationMode>(
                    title: Text(localizations.classicMode),
                    subtitle: Text(localizations.classicModeDescription),
                    value: CalculationMode.classic,
                    groupValue: currentCalculationMode,
                    onChanged: (CalculationMode? value) {
                      if (value != null) {
                        onCalculationModeChange(value);
                      }
                    },
                  ),
                  RadioListTile<CalculationMode>(
                    title: Text(localizations.logicMode),
                    subtitle: Text(localizations.logicModeDescription),
                    value: CalculationMode.logic,
                    groupValue: currentCalculationMode,
                    onChanged: (CalculationMode? value) {
                      if (value != null) {
                        onCalculationModeChange(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.language,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<Locale>(
                    title: const Text('English'),
                    value: const Locale('en'),
                    groupValue: currentLocale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        onLocaleChange(value);
                      }
                    },
                  ),
                  RadioListTile<Locale>(
                    title: const Text('中文'),
                    value: const Locale('zh'),
                    groupValue: currentLocale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        onLocaleChange(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.theme,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.light),
                    value: ThemeMode.light,
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        onThemeModeChange(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.dark),
                    value: ThemeMode.dark,
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        onThemeModeChange(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.system),
                    value: ThemeMode.system,
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        onThemeModeChange(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
