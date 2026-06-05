class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.code,
  });

  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final String? code;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromData,
  }) {
    final dynamic rawData = json['data'];

    return ApiResponse<T>(
      success: json['success'] == true,
      message: _parseMessage(json),
      statusCode: _parseStatusCode(json),
      code: json['code']?.toString(),
      data: fromData == null ? rawData as T? : fromData(rawData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'status_code': statusCode,
      'code': code,
    };
  }

  static String _parseMessage(Map<String, dynamic> json) {
    final dynamic message = json['message'] ??
        json['msg'] ??
        json['detail'] ??
        json['error'];

    if (message == null) {
      return 'Request completed.';
    }

    if (message is List) {
      return message.isEmpty ? 'Request completed.' : message.first.toString();
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
}