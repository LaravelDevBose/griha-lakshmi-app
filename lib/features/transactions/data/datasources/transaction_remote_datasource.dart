import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/transaction_response_model.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TransactionResponseModel> getTransactions({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getTransactionsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getTransactionsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<TransactionResponseModel> _getTransactionsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/transactions_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allTransactions = data['transactions'] ?? [];

    final int total = allTransactions.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedTransactions = startIndex >= total
        ? []
        : allTransactions.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    return TransactionResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': data['summary'],
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'transactions': paginatedTransactions,
      },
    });
  }

  Future<TransactionResponseModel> _getTransactionsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.transactions}?page=$page&per_page=$perPage';

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

    return TransactionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}