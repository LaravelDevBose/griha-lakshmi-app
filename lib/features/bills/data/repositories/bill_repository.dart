import '../datasources/bill_remote_datasource.dart';
import '../models/bill_action_response_model.dart';
import '../models/bill_response_model.dart';

class BillRepository {
  BillRepository({
    required BillRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BillRemoteDataSource _remoteDataSource;

  Future<BillResponseModel> getBills({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getBills(
      page: page,
      perPage: perPage,
    );
  }

  Future<BillActionResponseModel> storeBill({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeBill(payload: payload);
  }

  Future<BillActionResponseModel> updateBill({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateBill(
      id: id,
      payload: payload,
    );
  }

  Future<BillActionResponseModel> markBillPaid({
    required int id,
    required double paidAmount,
    required String paymentAccount,
  }) {
    return _remoteDataSource.markBillPaid(
      id: id,
      paidAmount: paidAmount,
      paymentAccount: paymentAccount,
    );
  }

  Future<BillActionResponseModel> snoozeBill({
    required int id,
  }) {
    return _remoteDataSource.snoozeBill(id: id);
  }
}