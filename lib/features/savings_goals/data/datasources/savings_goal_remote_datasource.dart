import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/savings_goal_action_response_model.dart';
import '../models/savings_goal_response_model.dart';

class SavingsGoalRemoteDataSource {
  SavingsGoalRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<SavingsGoalResponseModel> getSavingsGoals({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getSavingsGoalsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getSavingsGoalsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<SavingsGoalResponseModel> _getSavingsGoalsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/savings_goal_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allGoals = data['savings_goals'] ?? [];

    final int total = allGoals.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedGoals = startIndex >= total
        ? []
        : allGoals.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    int activeGoals = 0;
    int completedGoals = 0;
    double targetTotal = 0;
    double currentTotal = 0;
    double monthlyTargetTotal = 0;

    for (final dynamic item in allGoals) {
      if (item is Map<String, dynamic>) {
        final String status = item['status']?.toString().toLowerCase() ?? '';

        if (status == 'active') {
          activeGoals++;
        }

        if (status == 'completed') {
          completedGoals++;
        }

        targetTotal += double.tryParse(item['target_amount'].toString()) ?? 0;

        currentTotal += double.tryParse(item['current_amount'].toString()) ?? 0;

        monthlyTargetTotal +=
            double.tryParse(item['monthly_deposit_target'].toString()) ?? 0;
      }
    }

    return SavingsGoalResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_goals': total,
          'active_goals': activeGoals,
          'completed_goals': completedGoals,
          'target_total': targetTotal,
          'current_total': currentTotal,
          'monthly_target_total': monthlyTargetTotal,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'savings_goals': paginatedGoals,
      },
    });
  }

  Future<SavingsGoalResponseModel> _getSavingsGoalsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.savingsGoals}?page=$page&per_page=$perPage';

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

    return SavingsGoalResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<SavingsGoalActionResponseModel> storeSavingsGoal({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return SavingsGoalActionResponseModel.fromJson({
        'success': true,
        'message': 'Savings goal saved successfully',
        'status_code': 201,
        'code': 'SAVINGS_GOAL_CREATED',
        'data': {
          'savings_goal': {
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
      ApiEndpoints.storeSavingsGoal,
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

    return SavingsGoalActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<SavingsGoalActionResponseModel> updateSavingsGoal({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return SavingsGoalActionResponseModel.fromJson({
        'success': true,
        'message': 'Savings goal updated successfully',
        'status_code': 200,
        'code': 'SAVINGS_GOAL_UPDATED',
        'data': {
          'savings_goal': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateSavingsGoal(id),
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

    return SavingsGoalActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<SavingsGoalActionResponseModel> recordDeposit({
    required int id,
    required double depositAmount,
    required String account,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return SavingsGoalActionResponseModel.fromJson({
        'success': true,
        'message': 'Savings deposit recorded successfully',
        'status_code': 200,
        'code': 'SAVINGS_DEPOSIT_RECORDED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recordSavingsDeposit(id),
      token: token,
      body: {
        'deposit_amount': depositAmount,
        'account': account,
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

    return SavingsGoalActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}