import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PangoCalcApp());
}

class PangoCalcApp extends StatelessWidget {
  const PangoCalcApp({super.key});

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
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangolock Calculator'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
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
                        color: colorScheme.onSurface.withOpacity(0.6),
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
      ),
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
