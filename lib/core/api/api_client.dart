import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../app/app_config.dart';
import '../errors/error_handler.dart';
import '../errors/failure.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    return _sendRequest<T>(
      method: _ApiMethod.get,
      endpoint: endpoint,
      queryParameters: queryParameters,
      token: token,
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    return _sendRequest<T>(
      method: _ApiMethod.post,
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      token: token,
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    return _sendRequest<T>(
      method: _ApiMethod.put,
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      token: token,
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    return _sendRequest<T>(
      method: _ApiMethod.patch,
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      token: token,
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    return _sendRequest<T>(
      method: _ApiMethod.delete,
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      token: token,
      fromData: fromData,
    );
  }

  Future<ApiResponse<T>> _sendRequest<T>({
    required _ApiMethod method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    String? token,
    T Function(dynamic json)? fromData,
  }) async {
    try {
      if (AppConfig.useMockData) {
        throw const ApiException(
          failure: Failure(
            message:
                'ApiClient is disabled in mock mode. Use MockLoader until real API is ready.',
            code: 'MOCK_MODE_ENABLED',
          ),
        );
      }

      final Uri uri = _buildUri(
        endpoint: endpoint,
        queryParameters: queryParameters,
      );

      final Map<String, String> headers = _buildHeaders(token: token);

      late final http.Response response;

      switch (method) {
        case _ApiMethod.get:
          response = await _client
              .get(
                uri,
                headers: headers,
              )
              .timeout(_timeout);
          break;

        case _ApiMethod.post:
          response = await _client
              .post(
                uri,
                headers: headers,
                body: _encodeBody(body),
              )
              .timeout(_timeout);
          break;

        case _ApiMethod.put:
          response = await _client
              .put(
                uri,
                headers: headers,
                body: _encodeBody(body),
              )
              .timeout(_timeout);
          break;

        case _ApiMethod.patch:
          response = await _client
              .patch(
                uri,
                headers: headers,
                body: _encodeBody(body),
              )
              .timeout(_timeout);
          break;

        case _ApiMethod.delete:
          response = await _client
              .delete(
                uri,
                headers: headers,
                body: _encodeBody(body),
              )
              .timeout(_timeout);
          break;
      }

      return _handleResponse<T>(
        response: response,
        fromData: fromData,
      );
    } on ApiException {
      rethrow;
    } on SocketException catch (error) {
      throw ApiException(
        failure: ErrorHandler.handle(error),
      );
    } on TimeoutException catch (error) {
      throw ApiException(
        failure: ErrorHandler.handle(error),
      );
    } on FormatException catch (error) {
      throw ApiException(
        failure: ErrorHandler.handle(error),
      );
    } catch (error) {
      throw ApiException(
        failure: ErrorHandler.handle(error),
      );
    }
  }

  ApiResponse<T> _handleResponse<T>({
    required http.Response response,
    T Function(dynamic json)? fromData,
  }) {
    final int statusCode = response.statusCode;
    final dynamic decodedBody = _decodeBody(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          {
            ...decodedBody,
            'status_code': statusCode,
          },
          fromData: fromData,
        );
      }

      return ApiResponse<T>(
        success: true,
        message: 'Request successful.',
        statusCode: statusCode,
        data: decodedBody as T?,
      );
    }

    final Failure failure = ErrorHandler.handleApiResponse(
      statusCode: statusCode,
      responseBody: decodedBody,
    );

    ErrorHandler.logError(failure);

    throw ApiException(failure: failure);
  }

  Uri _buildUri({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) {
    final String baseUrl = AppConfig.apiBaseUrl;

    if (baseUrl.isEmpty) {
      throw const ApiException(
        failure: Failure(
          message: 'API base URL is empty. Check AppConfig environment.',
          code: 'EMPTY_API_BASE_URL',
        ),
      );
    }

    final String normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    final Uri uri = Uri.parse('$normalizedBaseUrl$normalizedEndpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  Map<String, String> _buildHeaders({
    String? token,
  }) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    return headers;
  }

  String? _encodeBody(Map<String, dynamic>? body) {
    if (body == null) {
      return null;
    }

    return jsonEncode(body);
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    return jsonDecode(body);
  }

  Duration get _timeout {
    return const Duration(
      seconds: AppConfig.apiTimeoutSeconds,
    );
  }

  void close() {
    _client.close();
  }
}

enum _ApiMethod {
  get,
  post,
  put,
  patch,
  delete,
}