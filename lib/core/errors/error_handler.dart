import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../app/app_config.dart';
import 'failure.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure handle(dynamic error) {
    if (error is Failure) {
      return error;
    }

    if (error is SocketException) {
      return const Failure(
        message: 'No internet connection. Please check your network.',
        code: 'NO_INTERNET',
      );
    }

    if (error is TimeoutException) {
      return const Failure(
        message: 'Request timeout. Please try again.',
        code: 'TIMEOUT',
      );
    }

    if (error is FormatException) {
      return const Failure(
        message: 'Invalid response format from server.',
        code: 'FORMAT_ERROR',
      );
    }

    if (error is PlatformException) {
      return Failure(
        message: error.message ?? 'Device error occurred.',
        code: error.code,
        exception: error,
      );
    }

    if (error is Map<String, dynamic>) {
      return Failure.fromJson(error);
    }

    return Failure(
      message: 'Something went wrong. Please try again.',
      code: 'UNKNOWN_ERROR',
      exception: error,
    );
  }

  static Failure handleApiResponse({
    required int statusCode,
    required dynamic responseBody,
  }) {
    final Map<String, dynamic> data = _parseResponseBody(responseBody);

    if (statusCode >= 200 && statusCode < 300) {
      return const Failure(
        message: 'This response is successful, not an error.',
        code: 'SUCCESS_RESPONSE',
      );
    }

    if (statusCode == 400) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'Bad request. Please check your input.',
        'code': data['code'] ?? 'BAD_REQUEST',
      });
    }

    if (statusCode == 401) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'Unauthorized. Please login again.',
        'code': data['code'] ?? 'UNAUTHORIZED',
      });
    }

    if (statusCode == 403) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'You do not have permission for this action.',
        'code': data['code'] ?? 'FORBIDDEN',
      });
    }

    if (statusCode == 404) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'Requested data was not found.',
        'code': data['code'] ?? 'NOT_FOUND',
      });
    }

    if (statusCode == 422) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'Validation failed. Please check your input.',
        'code': data['code'] ?? 'VALIDATION_ERROR',
      });
    }

    if (statusCode >= 500) {
      return Failure.fromJson({
        ...data,
        'status_code': statusCode,
        'message': data['message'] ?? 'Server error. Please try again later.',
        'code': data['code'] ?? 'SERVER_ERROR',
      });
    }

    return Failure.fromJson({
      ...data,
      'status_code': statusCode,
      'message': data['message'] ?? 'Unexpected error occurred.',
      'code': data['code'] ?? 'UNEXPECTED_ERROR',
    });
  }

  static Map<String, dynamic> _parseResponseBody(dynamic responseBody) {
    if (responseBody == null) {
      return {};
    }

    if (responseBody is Map<String, dynamic>) {
      return responseBody;
    }

    if (responseBody is String) {
      try {
        final dynamic decoded = jsonDecode(responseBody);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          'message': responseBody,
        };
      } catch (_) {
        return {
          'message': responseBody,
        };
      }
    }

    return {
      'message': responseBody.toString(),
    };
  }

  static void logError(Failure failure) {
    if (!AppConfig.enableDebugLogs) return;

    // For development only.
    // Later you can replace this with Firebase Crashlytics / Sentry.
    // ignore: avoid_print
    print('''
========== FamilyFund Error ==========
Message: ${failure.message}
Status Code: ${failure.statusCode}
Code: ${failure.code}
Validation Errors: ${failure.errors}
Exception: ${failure.exception}
======================================
''');
  }
}