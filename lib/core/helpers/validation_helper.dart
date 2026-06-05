import 'money_helper.dart';

class ValidationHelper {
  ValidationHelper._();

  static String? requiredField(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final RegExp emailRegex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return email(value);
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final String cleanPhone = value.trim();

    final RegExp bangladeshPhoneRegex = RegExp(
      r'^(?:\+88|88)?01[3-9]\d{8}$',
    );

    if (!bangladeshPhoneRegex.hasMatch(cleanPhone)) {
      return 'Enter a valid Bangladeshi phone number.';
    }

    return null;
  }

  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required.';
    }

    final String cleanValue = value.trim();

    if (cleanValue.contains('@')) {
      return email(cleanValue);
    }

    return phone(cleanValue);
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? confirmPassword(
    String? value, {
    required String password,
  }) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }

    if (value != password) {
      return 'Password and confirm password do not match.';
    }

    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }

    if (!MoneyHelper.isValidAmount(value)) {
      return 'Enter a valid amount.';
    }

    return null;
  }

  static String? optionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return amount(value);
  }

  static String? minAmount(
    String? value, {
    required num min,
  }) {
    final String? amountError = amount(value);

    if (amountError != null) {
      return amountError;
    }

    final num parsedAmount = MoneyHelper.parseAmount(value!);

    if (parsedAmount < min) {
      return 'Amount must be at least ${MoneyHelper.formatAmount(min)}.';
    }

    return null;
  }

  static String? maxAmount(
    String? value, {
    required num max,
  }) {
    final String? amountError = amount(value);

    if (amountError != null) {
      return amountError;
    }

    final num parsedAmount = MoneyHelper.parseAmount(value!);

    if (parsedAmount > max) {
      return 'Amount cannot be more than ${MoneyHelper.formatAmount(max)}.';
    }

    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required.';
    }

    return null;
  }

  static String? dropdown<T>(
    T? value, {
    String fieldName = 'This field',
  }) {
    if (value == null) {
      return '$fieldName is required.';
    }

    if (value is String && value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? minLength(
    String? value, {
    required int length,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    if (value.trim().length < length) {
      return '$fieldName must be at least $length characters.';
    }

    return null;
  }

  static String? maxLength(
    String? value, {
    required int length,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    if (value.trim().length > length) {
      return '$fieldName cannot be more than $length characters.';
    }

    return null;
  }

  static String? optionalMaxLength(
    String? value, {
    required int length,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > length) {
      return '$fieldName cannot be more than $length characters.';
    }

    return null;
  }

  static String? invitationCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Invitation code is required.';
    }

    if (value.trim().length < 4) {
      return 'Invitation code is too short.';
    }

    return null;
  }
}