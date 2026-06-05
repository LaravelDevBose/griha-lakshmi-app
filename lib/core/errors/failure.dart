class Failure {
  const Failure({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
    this.exception,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, List<String>>? errors;
  final Object? exception;

  bool get hasValidationErrors {
    return errors != null && errors!.isNotEmpty;
  }

  String get firstErrorMessage {
    if (!hasValidationErrors) {
      return message;
    }

    final firstFieldErrors = errors!.values.first;

    if (firstFieldErrors.isEmpty) {
      return message;
    }

    return firstFieldErrors.first;
  }

  List<String> get allErrorMessages {
    if (!hasValidationErrors) {
      return [message];
    }

    return errors!.values.expand((messages) => messages).toList();
  }

  factory Failure.fromJson(Map<String, dynamic> json) {
    return Failure(
      message: _parseMessage(json),
      statusCode: _parseStatusCode(json),
      code: json['code']?.toString(),
      errors: _parseValidationErrors(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'code': code,
      'errors': errors,
    };
  }

  static String _parseMessage(Map<String, dynamic> json) {
    final dynamic message = json['message'] ??
        json['error'] ??
        json['detail'] ??
        json['msg'];

    if (message == null) {
      return 'Something went wrong. Please try again.';
    }

    if (message is List) {
      return message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message.first.toString();
    }

    return message.toString();
  }

  static int? _parseStatusCode(Map<String, dynamic> json) {
    final dynamic statusCode = json['status_code'] ?? json['statusCode'];

    if (statusCode == null) {
      return null;
    }

    if (statusCode is int) {
      return statusCode;
    }

    return int.tryParse(statusCode.toString());
  }

  static Map<String, List<String>>? _parseValidationErrors(
    Map<String, dynamic> json,
  ) {
    final dynamic rawErrors = json['errors'];

    if (rawErrors == null || rawErrors is! Map) {
      return null;
    }

    final Map<String, List<String>> parsedErrors = {};

    rawErrors.forEach((key, value) {
      if (value is List) {
        parsedErrors[key.toString()] = value.map((item) => item.toString()).toList();
      } else {
        parsedErrors[key.toString()] = [value.toString()];
      }
    });

    return parsedErrors;
  }
}