import '../datasources/expense_remote_datasource.dart';
import '../models/expense_action_response_model.dart';
import '../models/expense_response_model.dart';

class ExpenseRepository {
  ExpenseRepository({
    required ExpenseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ExpenseRemoteDataSource _remoteDataSource;

  Future<ExpenseResponseModel> getExpenses({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getExpenses(
      page: page,
      perPage: perPage,
    );
  }

  Future<ExpenseActionResponseModel> storeExpense({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeExpense(payload: payload);
  }

  Future<ExpenseActionResponseModel> updateExpense({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateExpense(
      id: id,
      payload: payload,
    );
  }

  Future<ExpenseActionResponseModel> deleteExpense({
    required int id,
  }) {
    return _remoteDataSource.deleteExpense(id: id);
  }
}