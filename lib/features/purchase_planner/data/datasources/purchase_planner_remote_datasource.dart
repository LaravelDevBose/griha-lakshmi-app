import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/purchase_planner_action_response_model.dart';
import '../models/purchase_planner_response_model.dart';

class PurchasePlannerRemoteDataSource {
  PurchasePlannerRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PurchasePlannerResponseModel> getItems({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getItemsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getItemsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<PurchasePlannerResponseModel> _getItemsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/purchase_planner_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allItems = data['items'] ?? [];

    final int total = allItems.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedItems = startIndex >= total
        ? []
        : allItems.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    double estimatedTotal = 0;
    int urgentItems = 0;
    int completedItems = 0;

    for (final dynamic item in allItems) {
      if (item is Map<String, dynamic>) {
        estimatedTotal +=
            double.tryParse(item['estimated_price'].toString()) ?? 0;

        if (item['priority']?.toString().toLowerCase() == 'urgent') {
          urgentItems++;
        }

        if (item['status']?.toString().toLowerCase() == 'completed') {
          completedItems++;
        }
      }
    }

    return PurchasePlannerResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_items': total,
          'urgent_items': urgentItems,
          'completed_items': completedItems,
          'estimated_total': estimatedTotal,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'items': paginatedItems,
      },
    });
  }

  Future<PurchasePlannerResponseModel> _getItemsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.purchasePlannerItems}?page=$page&per_page=$perPage';

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      token: token,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> storeItem({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Purchase item saved successfully',
        'status_code': 201,
        'code': 'PURCHASE_ITEM_CREATED',
        'data': {
          'item': {
            'id': DateTime.now().millisecondsSinceEpoch,
            ...payload,
            'status': payload['status'] ?? 'pending',
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storePurchasePlannerItem,
      token: token,
      body: payload,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> updateItem({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Purchase item updated successfully',
        'status_code': 200,
        'code': 'PURCHASE_ITEM_UPDATED',
        'data': {
          'item': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updatePurchasePlannerItem(id),
      token: token,
      body: payload,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success || response.data == null) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> assignItem({
    required int id,
    required String assignedTo,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Purchase item assigned successfully',
        'status_code': 200,
        'code': 'PURCHASE_ITEM_ASSIGNED',
        'data': null,
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.assignPurchasePlannerItem(id),
      token: token,
      body: {
        'assigned_to': assignedTo,
      },
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> markPurchased({
    required int id,
    required double finalPrice,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Item marked as purchased',
        'status_code': 200,
        'code': 'PURCHASE_ITEM_COMPLETED',
        'data': null,
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.markPurchasePlannerItemPurchased(id),
      token: token,
      body: {
        'final_price': finalPrice,
      },
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> cancelItem({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Purchase item cancelled',
        'status_code': 200,
        'code': 'PURCHASE_ITEM_CANCELLED',
        'data': null,
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.cancelPurchasePlannerItem(id),
      token: token,
      body: const {},
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<PurchasePlannerActionResponseModel> deleteItem({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return PurchasePlannerActionResponseModel.fromJson({
        'success': true,
        'message': 'Purchase item deleted successfully',
        'status_code': 200,
        'code': 'PURCHASE_ITEM_DELETED',
        'data': null,
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.deletePurchasePlannerItem(id),
      token: token,
      fromData: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }

        return <String, dynamic>{};
      },
    );

    if (!response.success) {
      throw Failure(
        message: response.message,
        statusCode: response.statusCode,
        code: response.code,
      );
    }

    return PurchasePlannerActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}