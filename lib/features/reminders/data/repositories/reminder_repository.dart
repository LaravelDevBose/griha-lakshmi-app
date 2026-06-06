import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder_action_response_model.dart';
import '../models/reminder_response_model.dart';

class ReminderRepository {
  ReminderRepository({
    required ReminderRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ReminderRemoteDataSource _remoteDataSource;

  Future<ReminderResponseModel> getReminders({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getReminders(
      page: page,
      perPage: perPage,
    );
  }

  Future<ReminderActionResponseModel> storeReminder({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeReminder(payload: payload);
  }

  Future<ReminderActionResponseModel> updateReminder({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateReminder(
      id: id,
      payload: payload,
    );
  }

  Future<ReminderActionResponseModel> completeReminder({
    required int id,
  }) {
    return _remoteDataSource.completeReminder(id: id);
  }

  Future<ReminderActionResponseModel> snoozeReminder({
    required int id,
    required int snoozeMinutes,
  }) {
    return _remoteDataSource.snoozeReminder(
      id: id,
      snoozeMinutes: snoozeMinutes,
    );
  }
}