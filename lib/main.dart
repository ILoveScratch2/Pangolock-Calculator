import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'calculator_mode.dart';
import 'scientific_calculator.dart';

void main() {
  runApp(const PangoCalcApp());
}

class PangoCalcApp extends StatefulWidget {
  const PangoCalcApp({super.key});

  @override
  State<PangoCalcApp> createState() => _PangoCalcAppState();
}

class _PangoCalcAppState extends State<PangoCalcApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _changeThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangolock Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      home: CalculatorScreen(
        onLocaleChange: _changeLocale,
        onThemeModeChange: _changeThemeMode,
        currentLocale: _locale,
        currentThemeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Function(ThemeMode) onThemeModeChange;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;

  const CalculatorScreen({
    super.key,
    required this.onLocaleChange,
    required this.onThemeModeChange,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  CalculatorMode _currentMode = CalculatorMode.standard;
  String _display = '0';
  String _expression = '';
  double _result = 0;
  String _operation = '';
  double _operand = 0;
  bool _waitingForOperand = false;
  bool _hasDecimal = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_waitingForOperand) {
        _display = number;
        _waitingForOperand = false;
        _hasDecimal = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
      _expression = _expression.replaceAll('=', '');
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_waitingForOperand) {
        _display = '0.';
        _waitingForOperand = false;
        _hasDecimal = true;
      } else if (!_hasDecimal) {
        _display += '.';
        _hasDecimal = true;
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_operation.isNotEmpty && !_waitingForOperand) {
        _calculate();
      } else {
        _result = double.parse(_display);
      }

      _operation = operation;
      _operand = _result;
      _waitingForOperand = true;
      _hasDecimal = false;

      _expression = '${_formatNumber(_result)} $operation ';
    });
  }

  void _calculate() {
    double currentValue = double.parse(_display);

    switch (_operation) {
      case '+':
        _result = _operand + currentValue;
        break;
      case '-':
        _result = _operand - currentValue;
        break;
      case '×':
        _result = _operand * currentValue;
        break;
      case '÷':
        if (currentValue != 0) {
          _result = _operand / currentValue;
        } else {
          _result = double.infinity;
        }
        break;
      default:
        return;
    }

    _display = _formatNumber(_result);
  }

  void _onEqualsPressed() {
    setState(() {
      if (_operation.isNotEmpty && !_waitingForOperand) {
        _expression += '${_formatNumber(double.parse(_display))} = ';
        _calculate();
        _expression += _formatNumber(_result);
        _operation = '';
        _waitingForOperand = true;
        _hasDecimal = _display.contains('.');
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _result = 0;
      _operation = '';
      _operand = 0;
      _waitingForOperand = false;
      _hasDecimal = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_display.length > 1) {
        String newDisplay = _display.substring(0, _display.length - 1);
        if (_display.contains('.') && !newDisplay.contains('.')) {
          _hasDecimal = false;
        }
        _display = newDisplay;
      } else {
        _display = '0';
        _hasDecimal = false;
      }
    });
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      drawer: _buildDrawer(context, localizations),
      body: _currentMode == CalculatorMode.standard
        ? _buildStandardCalculator(context, theme, colorScheme)
        : const ScientificCalculator(),
    );
  }

  Widget _buildStandardCalculator(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Display area
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression display
                if (_expression.isNotEmpty)
                  Text(
                    _expression,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.end,
                  ),
                const SizedBox(height: 8),
                // Main display
                Text(
                  _display,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // Button grid
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: C, ⌫, ÷
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', _onClearPressed,
                        backgroundColor: colorScheme.errorContainer,
                        textColor: colorScheme.onErrorContainer,
                        flex: 2),
                      _buildButton('⌫', _onBackspacePressed,
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer),
                      _buildButton('÷', () => _onOperationPressed('÷'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 2: 7, 8, 9, ×
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', () => _onNumberPressed('7')),
                      _buildButton('8', () => _onNumberPressed('8')),
                      _buildButton('9', () => _onNumberPressed('9')),
                      _buildButton('×', () => _onOperationPressed('×'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 3: 4, 5, 6, -
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4', () => _onNumberPressed('4')),
                      _buildButton('5', () => _onNumberPressed('5')),
                      _buildButton('6', () => _onNumberPressed('6')),
                      _buildButton('-', () => _onOperationPressed('-'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 4: 1, 2, 3, +
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1', () => _onNumberPressed('1')),
                      _buildButton('2', () => _onNumberPressed('2')),
                      _buildButton('3', () => _onNumberPressed('3')),
                      _buildButton('+', () => _onOperationPressed('+'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 5: 0, ., =
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0', () => _onNumberPressed('0'), flex: 2),
                      _buildButton('.', _onDecimalPressed),
                      _buildButton('=', _onEqualsPressed,
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.calculate,
                  size: 48,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Mode selection
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text(localizations.mode),
            subtitle: Text(_currentMode == CalculatorMode.standard
              ? localizations.standardMode
              : localizations.scientificMode),
            onTap: () {
              _showModeDialog(context, localizations);
            },
          ),
          const Divider(),
          // Language selection
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.language),
            subtitle: Text(widget.currentLocale.languageCode == 'zh' ? '中文' : 'English'),
            onTap: () {
              _showLanguageDialog(context, localizations);
            },
          ),
          // Theme selection
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(localizations.theme),
            subtitle: Text(_getThemeModeText(localizations)),
            onTap: () {
              _showThemeDialog(context, localizations);
            },
          ),
          const Divider(),
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(localizations.about),
            onTap: () {
              _showAboutDialog(context, localizations);
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(AppLocalizations localizations) {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return localizations.light;
      case ThemeMode.dark:
        return localizations.dark;
      case ThemeMode.system:
        return localizations.system;
    }
  }

  void _showModeDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.mode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<CalculatorMode>(
                title: Text(localizations.standardMode),
                value: CalculatorMode.standard,
                groupValue: _currentMode,
                onChanged: (CalculatorMode? value) {
                  if (value != null) {
                    setState(() {
                      _currentMode = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<CalculatorMode>(
                title: Text(localizations.scientificMode),
                value: CalculatorMode.scientific,
                groupValue: _currentMode,
                onChanged: (CalculatorMode? value) {
                  if (value != null) {
                    setState(() {
                      _currentMode = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: widget.currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    widget.onLocaleChange(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('中文'),
                value: const Locale('zh'),
                groupValue: widget.currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    widget.onLocaleChange(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(localizations.light),
                value: ThemeMode.light,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChange(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(localizations.dark),
                value: ThemeMode.dark,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChange(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(localizations.system),
                value: ThemeMode.system,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChange(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showAboutDialog(
      context: context,
      applicationName: localizations.appTitle,
      applicationVersion: '0.2.0',
      applicationIcon: const Icon(Icons.calculate, size: 48),
      children: [
        Text('${localizations.version}: 0.2.0'),
        const SizedBox(height: 16),
        Text(localizations.appDescription),
        const SizedBox(height: 8),
        Text(localizations.license),
      ],
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color? backgroundColor,
    Color? textColor,
    int flex = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Material(
          color: backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: textColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
