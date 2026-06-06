import '../datasources/savings_goal_remote_datasource.dart';
import '../models/savings_goal_action_response_model.dart';
import '../models/savings_goal_response_model.dart';

class SavingsGoalRepository {
  SavingsGoalRepository({
    required SavingsGoalRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SavingsGoalRemoteDataSource _remoteDataSource;

  Future<SavingsGoalResponseModel> getSavingsGoals({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getSavingsGoals(
      page: page,
      perPage: perPage,
    );
  }

  Future<SavingsGoalActionResponseModel> storeSavingsGoal({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeSavingsGoal(payload: payload);
  }

  Future<SavingsGoalActionResponseModel> updateSavingsGoal({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateSavingsGoal(
      id: id,
      payload: payload,
    );
  }

  Future<SavingsGoalActionResponseModel> recordDeposit({
    required int id,
    required double depositAmount,
    required String account,
  }) {
    return _remoteDataSource.recordDeposit(
      id: id,
      depositAmount: depositAmount,
      account: account,
    );
  }
}