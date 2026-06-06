import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/expense_action_response_model.dart';
import '../models/expense_response_model.dart';

class ExpenseRemoteDataSource {
  ExpenseRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ExpenseResponseModel> getExpenses({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getExpensesWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getExpensesWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<ExpenseResponseModel> _getExpensesWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/expense_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allExpenses = data['expenses'] ?? [];

    final int total = allExpenses.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedExpenses = startIndex >= total
        ? []
        : allExpenses.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    double totalExpense = 0;

    for (final dynamic item in allExpenses) {
      if (item is Map<String, dynamic>) {
        totalExpense += double.tryParse(item['amount'].toString()) ?? 0;
      }
    }

    return ExpenseResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_expense': totalExpense,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'expenses': paginatedExpenses,
      },
    });
  }

  Future<ExpenseResponseModel> _getExpensesWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.expenses}?page=$page&per_page=$perPage';

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

    return ExpenseResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ExpenseActionResponseModel> storeExpense({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      return _storeExpenseWithMockData(payload: payload);
    }

    return _storeExpenseWithApi(payload: payload);
  }

  Future<ExpenseActionResponseModel> _storeExpenseWithMockData({
    required Map<String, dynamic> payload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> expense = {
      'id': DateTime.now().millisecondsSinceEpoch,
      ...payload,
    };

    return ExpenseActionResponseModel.fromJson({
      'success': true,
      'message': 'Expense saved successfully',
      'status_code': 201,
      'code': 'EXPENSE_CREATED',
      'data': {
        'expense': expense,
      },
    });
  }

  Future<ExpenseActionResponseModel> _storeExpenseWithApi({
    required Map<String, dynamic> payload,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeExpense,
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

    return ExpenseActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ExpenseActionResponseModel> updateExpense({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      return _updateExpenseWithMockData(
        id: id,
        payload: payload,
      );
    }

    return _updateExpenseWithApi(
      id: id,
      payload: payload,
    );
  }

  Future<ExpenseActionResponseModel> _updateExpenseWithMockData({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ExpenseActionResponseModel.fromJson({
      'success': true,
      'message': 'Expense updated successfully',
      'status_code': 200,
      'code': 'EXPENSE_UPDATED',
      'data': {
        'expense': {
          'id': id,
          ...payload,
        },
      },
    });
  }

  Future<ExpenseActionResponseModel> _updateExpenseWithApi({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateExpense(id),
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

    return ExpenseActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ExpenseActionResponseModel> deleteExpense({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      return _deleteExpenseWithMockData(id: id);
    }

    return _deleteExpenseWithApi(id: id);
  }

  Future<ExpenseActionResponseModel> _deleteExpenseWithMockData({
    required int id,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return ExpenseActionResponseModel.fromJson({
      'success': true,
      'message': 'Expense deleted successfully',
      'status_code': 200,
      'code': 'EXPENSE_DELETED',
      'data': null,
    });
  }

  Future<ExpenseActionResponseModel> _deleteExpenseWithApi({
    required int id,
  }) async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.deleteExpense(id),
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

    return ExpenseActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}