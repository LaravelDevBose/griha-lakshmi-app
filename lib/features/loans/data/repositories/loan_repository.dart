import '../datasources/loan_remote_datasource.dart';
import '../models/loan_action_response_model.dart';
import '../models/loan_response_model.dart';

class LoanRepository {
  LoanRepository({
    required LoanRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final LoanRemoteDataSource _remoteDataSource;

  Future<LoanResponseModel> getLoans({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getLoans(
      page: page,
      perPage: perPage,
    );
  }

  Future<LoanActionResponseModel> storeLoan({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeLoan(payload: payload);
  }

  Future<LoanActionResponseModel> updateLoan({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateLoan(
      id: id,
      payload: payload,
    );
  }

  Future<LoanActionResponseModel> recordPayment({
    required int id,
    required double paymentAmount,
    required String paymentAccount,
  }) {
    return _remoteDataSource.recordPayment(
      id: id,
      paymentAmount: paymentAmount,
      paymentAccount: paymentAccount,
    );
  }
}