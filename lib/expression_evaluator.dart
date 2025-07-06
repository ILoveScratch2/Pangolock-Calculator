import 'dart:math' as math;

class ExpressionEvaluator {
  static double evaluate(String expression) {
    try {
      // Remove spaces and replace operators with standard symbols
      String cleanExpression = expression
          .replaceAll(' ', '')
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      
      if (cleanExpression.isEmpty) return 0;
      
      return _evaluateExpression(cleanExpression);
    } catch (e) {
      return double.nan;
    }
  }

  static double _evaluateExpression(String expression) {
    // Handle parentheses first
    while (expression.contains('(')) {
      int start = expression.lastIndexOf('(');
      int end = expression.indexOf(')', start);
      if (end == -1) throw Exception('Mismatched parentheses');
      
      String subExpression = expression.substring(start + 1, end);
      double result = _evaluateExpression(subExpression);
      expression = expression.substring(0, start) + 
                  result.toString() + 
                  expression.substring(end + 1);
    }
    
    return _evaluateSimpleExpression(expression);
  }

  static double _evaluateSimpleExpression(String expression) {
    // Split into tokens (numbers and operators)
    List<String> tokens = _tokenize(expression);
    if (tokens.isEmpty) return 0;
    
    // Convert to postfix notation (Shunting Yard algorithm)
    List<String> postfix = _toPostfix(tokens);
    
    // Evaluate postfix expression
    return _evaluatePostfix(postfix);
  }

  static List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String currentNumber = '';
    
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      
      if (_isDigit(char) || char == '.') {
        currentNumber += char;
      } else if (_isOperator(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        
        // Handle negative numbers
        if (char == '-' && (tokens.isEmpty || _isOperator(tokens.last))) {
          currentNumber = '-';
        } else {
          tokens.add(char);
        }
      }
    }
    
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }
    
    return tokens;
  }

  static List<String> _toPostfix(List<String> tokens) {
    List<String> output = [];
    List<String> operators = [];
    
    for (String token in tokens) {
      if (_isNumber(token)) {
        output.add(token);
      } else if (_isOperator(token)) {
        while (operators.isNotEmpty &&
               _isOperator(operators.last) &&
               _getPrecedence(operators.last) >= _getPrecedence(token)) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      }
    }
    
    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }
    
    return output;
  }

  static double _evaluatePostfix(List<String> postfix) {
    List<double> stack = [];
    
    for (String token in postfix) {
      if (_isNumber(token)) {
        stack.add(double.parse(token));
      } else if (_isOperator(token)) {
        if (stack.length < 2) throw Exception('Invalid expression');
        
        double b = stack.removeLast();
        double a = stack.removeLast();
        
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0) throw Exception('Division by zero');
            stack.add(a / b);
            break;
          case '^':
            stack.add(math.pow(a, b).toDouble());
            break;
        }
      }
    }
    
    if (stack.length != 1) throw Exception('Invalid expression');
    return stack.first;
  }

  static bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  static bool _isOperator(String char) {
    return ['+', '-', '*', '/', '^'].contains(char);
  }

  static bool _isNumber(String token) {
    return double.tryParse(token) != null;
  }

  static int _getPrecedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }
}
