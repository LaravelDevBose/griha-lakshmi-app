import '../datasources/income_remote_datasource.dart';
import '../models/income_action_response_model.dart';
import '../models/income_response_model.dart';

class IncomeRepository {
  IncomeRepository({
    required IncomeRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final IncomeRemoteDataSource _remoteDataSource;

  Future<IncomeResponseModel> getIncomes({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getIncomes(
      page: page,
      perPage: perPage,
    );
  }

  Future<IncomeActionResponseModel> storeIncome({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeIncome(payload: payload);
  }

  Future<IncomeActionResponseModel> updateIncome({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateIncome(
      id: id,
      payload: payload,
    );
  }

  Future<IncomeActionResponseModel> deleteIncome({
    required int id,
  }) {
    return _remoteDataSource.deleteIncome(id: id);
  }
}