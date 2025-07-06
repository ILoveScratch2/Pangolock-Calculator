import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'calculator_mode.dart';
import 'expression_evaluator.dart';

class ScientificCalculator extends StatefulWidget {
  final CalculationMode calculationMode;
  final bool memoryKeysEnabled;

  const ScientificCalculator({
    super.key,
    required this.calculationMode,
    required this.memoryKeysEnabled,
  });

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _display = '0';
  String _expression = '';
  String _logicExpression = '';
  double _result = 0;
  String _operation = '';
  double _operand = 0;
  bool _waitingForOperand = false;
  bool _hasDecimal = false;
  bool _isRadians = true;
  double _memory = 0;

  void _onNumberPressed(String number) {
    setState(() {
      if (widget.calculationMode == CalculationMode.logic) {
        // Logic mode: handle number input for expression building
        if (_waitingForOperand || _display == '0') {
          _display = number;
          _waitingForOperand = false;
        } else {
          _display = _display + number;
        }
        _hasDecimal = _display.contains('.');

        if (_logicExpression.isNotEmpty) {
          String tempExpression = _logicExpression + _display;
          _expression = tempExpression;
        } else {
          _expression = '';
        }
      } else {
        // Classic mode: existing behavior
        if (_waitingForOperand) {
          _display = number;
          _waitingForOperand = false;
          _hasDecimal = false;
        } else {
          _display = _display == '0' ? number : _display + number;
        }
        _expression = _expression.replaceAll('=', '');
      }
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

      if (widget.calculationMode == CalculationMode.logic) {
        if (_logicExpression.isNotEmpty) {
          String tempExpression = _logicExpression + _display;
          _expression = tempExpression;
        }
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (widget.calculationMode == CalculationMode.logic) {
        // Logic mode: build expression string without calculating
        if (_logicExpression.isEmpty) {
          _logicExpression = _display;
        } else if (!_waitingForOperand) {
          _logicExpression += _display;
        }
        _logicExpression += ' $operation ';
        _expression = _logicExpression;
        _waitingForOperand = true;
        _hasDecimal = false;
      } else {
        // Classic mode: existing behavior
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
      }
    });
  }

  void _onScientificFunction(String function) {
    setState(() {
      double currentValue = double.parse(_display);
      double result = 0;
      
      switch (function) {
        case 'sin':
          result = _isRadians ? math.sin(currentValue) : math.sin(currentValue * math.pi / 180);
          break;
        case 'cos':
          result = _isRadians ? math.cos(currentValue) : math.cos(currentValue * math.pi / 180);
          break;
        case 'tan':
          result = _isRadians ? math.tan(currentValue) : math.tan(currentValue * math.pi / 180);
          break;
        case 'ln':
          result = math.log(currentValue);
          break;
        case 'log':
          result = math.log(currentValue) / math.log(10);
          break;
        case 'sqrt':
          result = math.sqrt(currentValue);
          break;
        case 'x²':
          result = currentValue * currentValue;
          break;
        case 'x³':
          result = currentValue * currentValue * currentValue;
          break;
        case '1/x':
          result = 1 / currentValue;
          break;
        case 'π':
          result = math.pi;
          break;
        case 'e':
          result = math.e;
          break;
        case '!':
          result = _factorial(currentValue.toInt());
          break;
        case '±':
          result = -currentValue;
          break;
      }
      
      _display = _formatNumber(result);
      _expression = '$function(${_formatNumber(currentValue)}) = ';
      _waitingForOperand = true;
      _hasDecimal = _display.contains('.');
    });
  }

  double _factorial(int n) {
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
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
      case '^':
        _result = math.pow(_operand, currentValue).toDouble();
        break;
      default:
        return;
    }
    
    _display = _formatNumber(_result);
  }

  void _onEqualsPressed() {
    setState(() {
      if (widget.calculationMode == CalculationMode.logic) {
        // Logic mode: evaluate complete expression
        if (_logicExpression.isNotEmpty) {
          String completeExpression = _logicExpression;
          if (!_waitingForOperand) {
            completeExpression += _display;
          }

          try {
            _result = ExpressionEvaluator.evaluate(completeExpression);
            _expression = '$completeExpression = ${_formatNumber(_result)}';
            _display = _formatNumber(_result);
            _logicExpression = '';
            _waitingForOperand = true;
            _hasDecimal = _display.contains('.');
          } catch (e) {
            _display = 'Error';
            _expression = 'Error';
            _logicExpression = '';
          }
        }
      } else {
        // Classic mode: existing behavior
        if (_operation.isNotEmpty && !_waitingForOperand) {
          _expression += '${_formatNumber(double.parse(_display))} = ';
          _calculate();
          _expression += _formatNumber(_result);
          _operation = '';
          _waitingForOperand = true;
          _hasDecimal = _display.contains('.');
        }
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _logicExpression = '';
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

  void _onMemoryAdd() {
    setState(() {
      _memory += double.parse(_display);
    });
  }

  void _onMemorySubtract() {
    setState(() {
      _memory -= double.parse(_display);
    });
  }

  void _onMemoryRecall() {
    setState(() {
      _display = _formatNumber(_memory);
      _waitingForOperand = true;
      _hasDecimal = _display.contains('.');
    });
  }

  void _onMemoryClear() {
    setState(() {
      _memory = 0;
    });
  }

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color? backgroundColor,
    Color? textColor,
    int flex = 1,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Material(
          color: backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                // Memory indicator
                if (widget.memoryKeysEnabled && _memory != 0)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'M',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
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
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Memory Keys Row (conditional)
                if (widget.memoryKeysEnabled)
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('MC', _onMemoryClear,
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                          fontSize: 12),
                        _buildButton('MR', _onMemoryRecall,
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                          fontSize: 12),
                        _buildButton('M+', _onMemoryAdd,
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                          fontSize: 12),
                        _buildButton('M-', _onMemorySubtract,
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                          fontSize: 12),
                      ],
                    ),
                  ),
                // Row 1: Functions
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', _onClearPressed, 
                        backgroundColor: colorScheme.errorContainer,
                        textColor: colorScheme.onErrorContainer),
                      _buildButton('⌫', _onBackspacePressed,
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer),
                      _buildButton(_isRadians ? 'RAD' : 'DEG', () {
                        setState(() {
                          _isRadians = !_isRadians;
                        });
                      }, backgroundColor: colorScheme.tertiaryContainer,
                        textColor: colorScheme.onTertiaryContainer, fontSize: 12),
                      _buildButton('÷', () => _onOperationPressed('÷'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 2: Scientific functions
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('sin', () => _onScientificFunction('sin'), fontSize: 12),
                      _buildButton('cos', () => _onScientificFunction('cos'), fontSize: 12),
                      _buildButton('tan', () => _onScientificFunction('tan'), fontSize: 12),
                      _buildButton('×', () => _onOperationPressed('×'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 3: More functions and numbers
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('ln', () => _onScientificFunction('ln'), fontSize: 12),
                      _buildButton('log', () => _onScientificFunction('log'), fontSize: 12),
                      _buildButton('√', () => _onScientificFunction('sqrt')),
                      _buildButton('-', () => _onOperationPressed('-'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 4: Numbers and functions
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('x²', () => _onScientificFunction('x²'), fontSize: 12),
                      _buildButton('x³', () => _onScientificFunction('x³'), fontSize: 12),
                      _buildButton('^', () => _onOperationPressed('^')),
                      _buildButton('+', () => _onOperationPressed('+'),
                        backgroundColor: colorScheme.primaryContainer,
                        textColor: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
                // Row 5: Numbers
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', () => _onNumberPressed('7')),
                      _buildButton('8', () => _onNumberPressed('8')),
                      _buildButton('9', () => _onNumberPressed('9')),
                      _buildButton('!', () => _onScientificFunction('!')),
                    ],
                  ),
                ),
                // Row 6: Numbers
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4', () => _onNumberPressed('4')),
                      _buildButton('5', () => _onNumberPressed('5')),
                      _buildButton('6', () => _onNumberPressed('6')),
                      _buildButton('1/x', () => _onScientificFunction('1/x'), fontSize: 12),
                    ],
                  ),
                ),
                // Row 7: Numbers and constants
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1', () => _onNumberPressed('1')),
                      _buildButton('2', () => _onNumberPressed('2')),
                      _buildButton('3', () => _onNumberPressed('3')),
                      _buildButton('π', () => _onScientificFunction('π')),
                    ],
                  ),
                ),
                // Row 8: Final row
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('±', () => _onScientificFunction('±')),
                      _buildButton('0', () => _onNumberPressed('0')),
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
}
