import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/theme.dart';
import '../helpers/money_helper.dart';

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
    this.compact = false,
    this.maxLines = 1,
  });

  final num amount;
  final AmountTextType type;
  final String currency;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showPlusMinus;
  final bool compact;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final String prefix = _prefix;
    final String formattedAmount = compact
        ? MoneyHelper.formatCompactAmount(
            amount,
            currency: currency,
          )
        : MoneyHelper.formatAmount(
            amount,
            currency: currency,
          );

    return Text(
      '$prefix$formattedAmount',
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
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