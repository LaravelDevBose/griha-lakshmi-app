import '../datasources/account_remote_datasource.dart';
import '../models/account_action_response_model.dart';
import '../models/account_response_model.dart';

class AccountRepository {
  AccountRepository({
    required AccountRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AccountRemoteDataSource _remoteDataSource;

  Future<AccountResponseModel> getAccounts({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getAccounts(
      page: page,
      perPage: perPage,
    );
  }

  Future<AccountActionResponseModel> storeAccount({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeAccount(payload: payload);
  }

  Future<AccountActionResponseModel> updateAccount({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateAccount(
      id: id,
      payload: payload,
    );
  }

  Future<AccountActionResponseModel> deactivateAccount({
    required int id,
  }) {
    return _remoteDataSource.deactivateAccount(id: id);
  }

  Future<AccountActionResponseModel> setDefaultAccount({
    required int id,
  }) {
    return _remoteDataSource.setDefaultAccount(id: id);
  }
}