import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'calculator_mode.dart';

class SettingsPage extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  final Function(ThemeMode) onThemeModeChange;
  final Function(CalculationMode) onCalculationModeChange;
  final Function(bool) onMemoryKeysEnabledChange;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final CalculationMode currentCalculationMode;
  final bool memoryKeysEnabled;

  const SettingsPage({
    super.key,
    required this.onLocaleChange,
    required this.onThemeModeChange,
    required this.onCalculationModeChange,
    required this.onMemoryKeysEnabledChange,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.currentCalculationMode,
    required this.memoryKeysEnabled,
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

          // Memory Keys Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.memoryKeys,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(localizations.memoryKeys),
                    subtitle: Text(localizations.memoryKeysDescription),
                    value: memoryKeysEnabled,
                    onChanged: (bool value) {
                      onMemoryKeysEnabledChange(value);
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
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(localizations.language),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DropdownButtonFormField<Locale>(
                        value: currentLocale,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem<Locale>(
                            value: Locale('en'),
                            child: Row(
                              children: [
                                Text('🇺🇸'),
                                SizedBox(width: 8),
                                Text('English'),
                              ],
                            ),
                          ),
                          DropdownMenuItem<Locale>(
                            value: Locale('zh'),
                            child: Row(
                              children: [
                                Text('🇨🇳'),
                                SizedBox(width: 8),
                                Text('中文'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (Locale? value) {
                          if (value != null) {
                            onLocaleChange(value);
                          }
                        },
                      ),
                    ),
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
