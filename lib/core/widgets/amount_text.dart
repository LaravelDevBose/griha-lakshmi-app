import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/theme.dart';

enum AmountTextType {
  normal,
  income,
  expense,
  warning,
}

class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.type = AmountTextType.normal,
    this.currency = AppConstants.defaultCurrency,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w700,
    this.showPlusMinus = false,
  });

  final num amount;
  final AmountTextType type;
  final String currency;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showPlusMinus;

  @override
  Widget build(BuildContext context) {
    final String prefix = _prefix;
    final String formattedAmount = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );

    return Text(
      '$prefix$currency$formattedAmount',
      style: TextStyle(
        color: _color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  String get _prefix {
    if (!showPlusMinus) return '';

    switch (type) {
      case AmountTextType.income:
        return '+ ';
      case AmountTextType.expense:
        return '- ';
      case AmountTextType.normal:
      case AmountTextType.warning:
        return '';
    }
  }

  Color get _color {
    switch (type) {
      case AmountTextType.income:
        return AppColors.success;
      case AmountTextType.expense:
        return AppColors.danger;
      case AmountTextType.warning:
        return AppColors.warning;
      case AmountTextType.normal:
        return AppColors.textPrimary;
    }
  }
}