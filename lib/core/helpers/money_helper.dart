import '../../app/app_constants.dart';

class MoneyHelper {
  MoneyHelper._();

  /// Format: ৳25,000
  static String formatAmount(
    num amount, {
    String currency = AppConstants.defaultCurrency,
    bool showDecimal = false,
    bool showCurrency = true,
  }) {
    final String formattedNumber = _formatNumber(
      amount,
      showDecimal: showDecimal,
    );

    if (!showCurrency) {
      return formattedNumber;
    }

    return '$currency$formattedNumber';
  }

  /// Format: + ৳25,000 or - ৳25,000
  static String formatSignedAmount(
    num amount, {
    String currency = AppConstants.defaultCurrency,
    bool showDecimal = false,
    bool isIncome = false,
  }) {
    final String sign = isIncome ? '+ ' : '- ';
    final String formattedAmount = formatAmount(
      amount.abs(),
      currency: currency,
      showDecimal: showDecimal,
    );

    return '$sign$formattedAmount';
  }

  /// Format: 25000.50
  /// Useful before sending amount to API.
  static String formatApiAmount(num amount) {
    return amount.toStringAsFixed(2);
  }

  static num parseAmount(String value) {
    final String cleanValue = value
        .replaceAll(AppConstants.defaultCurrency, '')
        .replaceAll(',', '')
        .trim();

    return num.tryParse(cleanValue) ?? 0;
  }

  static bool isValidAmount(String value) {
    final num amount = parseAmount(value);

    return amount > 0;
  }

  static num calculateBalance({required num income, required num expense}) {
    return income - expense;
  }

  static num calculateSavings({required num income, required num expense}) {
    final num balance = calculateBalance(income: income, expense: expense);

    return balance < 0 ? 0 : balance;
  }

  static double calculatePercentage({
    required num current,
    required num target,
  }) {
    if (target <= 0) {
      return 0;
    }

    final double percentage = (current / target) * 100;

    if (percentage < 0) {
      return 0;
    }

    if (percentage > 100) {
      return 100;
    }

    return percentage;
  }

  static double calculateProgress({required num current, required num target}) {
    if (target <= 0) {
      return 0;
    }

    final double progress = current / target;

    if (progress < 0) {
      return 0;
    }

    if (progress > 1) {
      return 1;
    }

    return progress;
  }

  static String formatPercentage(num value, {int decimal = 0}) {
    return '${value.toStringAsFixed(decimal)}%';
  }

  static String _formatNumber(num amount, {required bool showDecimal}) {
    final String fixedAmount = showDecimal
        ? amount.toStringAsFixed(2)
        : amount.round().toString();

    final List<String> parts = fixedAmount.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '';

    final String formattedInteger = _addComma(integerPart);

    if (showDecimal) {
      return '$formattedInteger.$decimalPart';
    }

    return formattedInteger;
  }

  static String _addComma(String value) {
    final StringBuffer buffer = StringBuffer();

    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  static String formatCompactAmount(
    num amount, {
    String currency = AppConstants.defaultCurrency,
  }) {
    final num absAmount = amount.abs();

    if (absAmount >= 10000000) {
      return '$currency${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (absAmount >= 100000) {
      return '$currency${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (absAmount >= 1000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    }

    return formatAmount(amount, currency: currency);
  }
}
