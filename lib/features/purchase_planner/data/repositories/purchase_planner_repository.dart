import '../datasources/purchase_planner_remote_datasource.dart';
import '../models/purchase_planner_action_response_model.dart';
import '../models/purchase_planner_response_model.dart';

class PurchasePlannerRepository {
  PurchasePlannerRepository({
    required PurchasePlannerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PurchasePlannerRemoteDataSource _remoteDataSource;

  Future<PurchasePlannerResponseModel> getItems({
    required int page,
    required int perPage,
  }) {
    return _remoteDataSource.getItems(
      page: page,
      perPage: perPage,
    );
  }

  Future<PurchasePlannerActionResponseModel> storeItem({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.storeItem(payload: payload);
  }

  Future<PurchasePlannerActionResponseModel> updateItem({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateItem(
      id: id,
      payload: payload,
    );
  }

  Future<PurchasePlannerActionResponseModel> assignItem({
    required int id,
    required String assignedTo,
  }) {
    return _remoteDataSource.assignItem(
      id: id,
      assignedTo: assignedTo,
    );
  }

  Future<PurchasePlannerActionResponseModel> markPurchased({
    required int id,
    required double finalPrice,
  }) {
    return _remoteDataSource.markPurchased(
      id: id,
      finalPrice: finalPrice,
    );
  }

  Future<PurchasePlannerActionResponseModel> cancelItem({
    required int id,
  }) {
    return _remoteDataSource.cancelItem(id: id);
  }

  Future<PurchasePlannerActionResponseModel> deleteItem({
    required int id,
  }) {
    return _remoteDataSource.deleteItem(id: id);
  }
}