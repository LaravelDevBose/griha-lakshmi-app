import '../datasources/credit_card_remote_datasource.dart';
import '../models/credit_card_action_response_model.dart';
import '../models/credit_card_response_model.dart';

class CreditCardRepository {
  CreditCardRepository({
    required CreditCardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CreditCardRemoteDataSource _remoteDataSource;

  Future<CreditCardResponseModel> getCreditCards({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getCreditCards(
      page: page,
      perPage: perPage,
    );
  }

  Future<CreditCardActionResponseModel> storeCreditCard({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeCreditCard(payload: payload);
  }

  Future<CreditCardActionResponseModel> updateCreditCard({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateCreditCard(
      id: id,
      payload: payload,
    );
  }

  Future<CreditCardActionResponseModel> recordPayment({
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