import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/account_action_response_model.dart';
import '../models/account_response_model.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AccountResponseModel> getAccounts({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getAccountsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getAccountsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<AccountResponseModel> _getAccountsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/account_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allAccounts = data['accounts'] ?? [];

    final int total = allAccounts.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedAccounts = startIndex >= total
        ? []
        : allAccounts.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    int activeAccounts = 0;
    double totalBalance = 0;

    for (final dynamic item in allAccounts) {
      if (item is Map<String, dynamic>) {
        final String status = item['status']?.toString().toLowerCase() ?? '';

        if (status == 'active') {
          activeAccounts++;
          totalBalance +=
              double.tryParse(item['current_balance'].toString()) ?? 0;
        }
      }
    }

    return AccountResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_accounts': total,
          'active_accounts': activeAccounts,
          'total_balance': totalBalance,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'accounts': paginatedAccounts,
      },
    });
  }

  Future<AccountResponseModel> _getAccountsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.accounts}?page=$page&per_page=$perPage';

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

    return AccountResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<AccountActionResponseModel> storeAccount({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return AccountActionResponseModel.fromJson({
        'success': true,
        'message': 'Account saved successfully',
        'status_code': 201,
        'code': 'ACCOUNT_CREATED',
        'data': {
          'account': {
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
      ApiEndpoints.storeAccount,
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

    return AccountActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<AccountActionResponseModel> updateAccount({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return AccountActionResponseModel.fromJson({
        'success': true,
        'message': 'Account updated successfully',
        'status_code': 200,
        'code': 'ACCOUNT_UPDATED',
        'data': {
          'account': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateAccount(id),
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

    return AccountActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<AccountActionResponseModel> deactivateAccount({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return AccountActionResponseModel.fromJson({
        'success': true,
        'message': 'Account deactivated successfully',
        'status_code': 200,
        'code': 'ACCOUNT_DEACTIVATED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.deactivateAccount(id),
      token: token,
      body: const {},
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

    return AccountActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<AccountActionResponseModel> setDefaultAccount({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return AccountActionResponseModel.fromJson({
        'success': true,
        'message': 'Default account updated successfully',
        'status_code': 200,
        'code': 'DEFAULT_ACCOUNT_UPDATED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.setDefaultAccount(id),
      token: token,
      body: const {},
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

    return AccountActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}