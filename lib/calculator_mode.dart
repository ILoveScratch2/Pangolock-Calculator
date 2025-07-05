enum CalculatorMode {
  standard,
  scientific,
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
