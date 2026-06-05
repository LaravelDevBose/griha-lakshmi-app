import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationModel>> getNotifications() async {
    if (AppConfig.useMockData) {
      return _getNotificationsWithMockData();
    }

    return _getNotificationsWithApi();
  }

  Future<int> getUnreadNotificationCount() async {
    final List<NotificationModel> notifications = await getNotifications();

    return notifications.where((item) => !item.isRead).length;
  }

  Future<List<NotificationModel>> _getNotificationsWithMockData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/notifications_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final dynamic data = response['data'];

    if (data is! Map<String, dynamic>) {
      return [];
    }

    final dynamic notificationList = data['notifications'];

    if (notificationList is! List) {
      return [];
    }

    return notificationList
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<NotificationModel>> _getNotificationsWithApi() async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
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

    final dynamic notificationList = response.data!['notifications'];

    if (notificationList is! List) {
      return [];
    }

    return notificationList
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}