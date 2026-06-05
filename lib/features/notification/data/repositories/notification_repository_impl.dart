import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notificationModels = await _remoteDataSource.getNotifications();

    return notificationModels.map((item) => item.toEntity()).toList();
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    return _remoteDataSource.getUnreadNotificationCount();
  }
}