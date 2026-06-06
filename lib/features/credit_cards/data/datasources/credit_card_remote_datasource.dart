import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/credit_card_action_response_model.dart';
import '../models/credit_card_response_model.dart';

class CreditCardRemoteDataSource {
  CreditCardRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CreditCardResponseModel> getCreditCards({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getCreditCardsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getCreditCardsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<CreditCardResponseModel> _getCreditCardsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/credit_card_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allCards = data['credit_cards'] ?? [];

    final int total = allCards.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedCards = startIndex >= total
        ? []
        : allCards.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    double totalLimit = 0;
    double totalOutstandingBalance = 0;
    double minimumPaymentTotal = 0;

    for (final dynamic item in allCards) {
      if (item is Map<String, dynamic>) {
        totalLimit += double.tryParse(item['credit_limit'].toString()) ?? 0;

        totalOutstandingBalance +=
            double.tryParse(item['outstanding_balance'].toString()) ?? 0;

        minimumPaymentTotal +=
            double.tryParse(item['minimum_payment'].toString()) ?? 0;
      }
    }

    return CreditCardResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_cards': total,
          'total_limit': totalLimit,
          'total_outstanding_balance': totalOutstandingBalance,
          'minimum_payment_total': minimumPaymentTotal,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'credit_cards': paginatedCards,
      },
    });
  }

  Future<CreditCardResponseModel> _getCreditCardsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.creditCards}?page=$page&per_page=$perPage';

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      token: token,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return CreditCardResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<CreditCardActionResponseModel> storeCreditCard({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return CreditCardActionResponseModel.fromJson({
        'success': true,
        'message': 'Credit card saved successfully',
        'status_code': 201,
        'code': 'CREDIT_CARD_CREATED',
        'data': {
          'credit_card': {
            'id': DateTime.now().millisecondsSinceEpoch,
            ...payload,
            'status': payload['status'] ?? 'active',
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeCreditCard,
      token: token,
      body: payload,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return CreditCardActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<CreditCardActionResponseModel> updateCreditCard({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return CreditCardActionResponseModel.fromJson({
        'success': true,
        'message': 'Credit card updated successfully',
        'status_code': 200,
        'code': 'CREDIT_CARD_UPDATED',
        'data': {
          'credit_card': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateCreditCard(id),
      token: token,
      body: payload,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return CreditCardActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<CreditCardActionResponseModel> recordPayment({
    required int id,
    required double paymentAmount,
    required String paymentAccount,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return CreditCardActionResponseModel.fromJson({
        'success': true,
        'message': 'Credit card payment recorded and expense created',
        'status_code': 200,
        'code': 'CREDIT_CARD_PAYMENT_RECORDED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recordCreditCardPayment(id),
      token: token,
      body: {
        'payment_amount': paymentAmount,
        'payment_account': paymentAccount,
      },
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return CreditCardActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}