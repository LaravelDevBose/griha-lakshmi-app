import '../datasources/budget_remote_datasource.dart';
import '../models/budget_action_response_model.dart';
import '../models/budget_response_model.dart';

class BudgetRepository {
  BudgetRepository({
    required BudgetRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BudgetRemoteDataSource _remoteDataSource;

  Future<BudgetResponseModel> getCurrentBudget() {
    return _remoteDataSource.getCurrentBudget();
  }

  Future<BudgetActionResponseModel> storeBudget({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeBudget(payload: payload);
  }

  Future<BudgetActionResponseModel> updateBudget({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateBudget(
      id: id,
      payload: payload,
    );
  }
}