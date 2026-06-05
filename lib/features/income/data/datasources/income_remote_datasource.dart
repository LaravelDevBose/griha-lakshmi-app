import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/income_action_response_model.dart';
import '../models/income_response_model.dart';

class IncomeRemoteDataSource {
  IncomeRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<IncomeResponseModel> getIncomes({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getIncomesWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getIncomesWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<IncomeResponseModel> _getIncomesWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/income_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allIncomes = data['incomes'] ?? [];

    final int total = allIncomes.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedIncomes = startIndex >= total
        ? []
        : allIncomes.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    double totalIncome = 0;

    for (final dynamic item in allIncomes) {
      if (item is Map<String, dynamic>) {
        totalIncome += double.tryParse(item['amount'].toString()) ?? 0;
      }
    }

    return IncomeResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_income': totalIncome,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'incomes': paginatedIncomes,
      },
    });
  }

  Future<IncomeResponseModel> _getIncomesWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.incomes}?page=$page&per_page=$perPage';

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

    return IncomeResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<IncomeActionResponseModel> storeIncome({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      return _storeIncomeWithMockData(payload: payload);
    }

    return _storeIncomeWithApi(payload: payload);
  }

  Future<IncomeActionResponseModel> _storeIncomeWithMockData({
    required Map<String, dynamic> payload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> income = {
      'id': DateTime.now().millisecondsSinceEpoch,
      ...payload,
    };

    return IncomeActionResponseModel.fromJson({
      'success': true,
      'message': 'Income saved successfully',
      'status_code': 201,
      'code': 'INCOME_CREATED',
      'data': {
        'income': income,
      },
    });
  }

  Future<IncomeActionResponseModel> _storeIncomeWithApi({
    required Map<String, dynamic> payload,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeIncome,
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

    return IncomeActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<IncomeActionResponseModel> updateIncome({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      return _updateIncomeWithMockData(
        id: id,
        payload: payload,
      );
    }

    return _updateIncomeWithApi(
      id: id,
      payload: payload,
    );
  }

  Future<IncomeActionResponseModel> _updateIncomeWithMockData({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return IncomeActionResponseModel.fromJson({
      'success': true,
      'message': 'Income updated successfully',
      'status_code': 200,
      'code': 'INCOME_UPDATED',
      'data': {
        'income': {
          'id': id,
          ...payload,
        },
      },
    });
  }

  Future<IncomeActionResponseModel> _updateIncomeWithApi({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateIncome(id),
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

    return IncomeActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<IncomeActionResponseModel> deleteIncome({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      return _deleteIncomeWithMockData(id: id);
    }

    return _deleteIncomeWithApi(id: id);
  }

  Future<IncomeActionResponseModel> _deleteIncomeWithMockData({
    required int id,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return IncomeActionResponseModel.fromJson({
      'success': true,
      'message': 'Income deleted successfully',
      'status_code': 200,
      'code': 'INCOME_DELETED',
      'data': null,
    });
  }

  Future<IncomeActionResponseModel> _deleteIncomeWithApi({
    required int id,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.deleteIncome(id),
      token: token,
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

    return IncomeActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}