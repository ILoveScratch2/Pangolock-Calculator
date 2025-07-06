enum CalculatorMode {
  standard,
  scientific,
}

enum CalculationMode {
  classic,
  logic,
}

extension CalculatorModeExtension on CalculatorMode {
  String get name {
    switch (this) {
      case CalculatorMode.standard:
        return 'standard';
      case CalculatorMode.scientific:
        return 'scientific';
    }
  }
}

extension CalculationModeExtension on CalculationMode {
  String get name {
    switch (this) {
      case CalculationMode.classic:
        return 'classic';
      case CalculationMode.logic:
        return 'logic';
    }
  }
}
