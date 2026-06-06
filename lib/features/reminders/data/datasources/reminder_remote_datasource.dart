import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/reminder_action_response_model.dart';
import '../models/reminder_response_model.dart';

class ReminderRemoteDataSource {
  ReminderRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ReminderResponseModel> getReminders({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getRemindersWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getRemindersWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<ReminderResponseModel> _getRemindersWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/reminder_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allReminders = data['reminders'] ?? [];

    final int total = allReminders.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedReminders = startIndex >= total
        ? []
        : allReminders.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    int todayReminders = 0;
    int upcomingReminders = 0;
    int completedReminders = 0;
    int snoozedReminders = 0;

    for (final dynamic item in allReminders) {
      if (item is Map<String, dynamic>) {
        final String status = item['status']?.toString().toLowerCase() ?? '';

        if (status == 'today') {
          todayReminders++;
        } else if (status == 'upcoming') {
          upcomingReminders++;
        } else if (status == 'completed') {
          completedReminders++;
        } else if (status == 'snoozed') {
          snoozedReminders++;
        }
      }
    }

    return ReminderResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_reminders': total,
          'today_reminders': todayReminders,
          'upcoming_reminders': upcomingReminders,
          'completed_reminders': completedReminders,
          'snoozed_reminders': snoozedReminders,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'reminders': paginatedReminders,
      },
    });
  }

  Future<ReminderResponseModel> _getRemindersWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.reminders}?page=$page&per_page=$perPage';

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

    return ReminderResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ReminderActionResponseModel> storeReminder({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return ReminderActionResponseModel.fromJson({
        'success': true,
        'message': 'Reminder saved successfully',
        'status_code': 201,
        'code': 'REMINDER_CREATED',
        'data': {
          'reminder': {
            'id': DateTime.now().millisecondsSinceEpoch,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeReminder,
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

    return ReminderActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ReminderActionResponseModel> updateReminder({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return ReminderActionResponseModel.fromJson({
        'success': true,
        'message': 'Reminder updated successfully',
        'status_code': 200,
        'code': 'REMINDER_UPDATED',
        'data': {
          'reminder': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateReminder(id),
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

    return ReminderActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ReminderActionResponseModel> completeReminder({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return ReminderActionResponseModel.fromJson({
        'success': true,
        'message': 'Reminder completed successfully',
        'status_code': 200,
        'code': 'REMINDER_COMPLETED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.completeReminder(id),
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

    return ReminderActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<ReminderActionResponseModel> snoozeReminder({
    required int id,
    required int snoozeMinutes,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return ReminderActionResponseModel.fromJson({
        'success': true,
        'message': 'Reminder snoozed successfully',
        'status_code': 200,
        'code': 'REMINDER_SNOOZED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.snoozeReminder(id),
      token: token,
      body: {
        'snooze_minutes': snoozeMinutes,
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

    return ReminderActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}