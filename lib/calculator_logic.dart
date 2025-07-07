class CalculatorLogic {
  static String formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      String result = number.toString();
      if (result.contains('.')) {
        result = result.replaceAll(RegExp(r'0*$'), '');
        result = result.replaceAll(RegExp(r'\.$'), '');
      }
      return result;
    }
  }

  static double calculate(double first, double second, String operation) {
    switch (operation) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        return first / second;
      default:
        return second;
    }
  }

  static bool isValidNumberInput(String currentDisplay, String input) {
    if (input == '0' && currentDisplay == '0') {
      return false;
    }
    if (input == '.' && currentDisplay.contains('.')) {
      return false;
    }
    return true;
  }
}
