import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_response_model.dart';

class TransactionRepository {
  TransactionRepository({
    required TransactionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TransactionRemoteDataSource _remoteDataSource;

  Future<TransactionResponseModel> getTransactions({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getTransactions(
      page: page,
      perPage: perPage,
    );
  }
}