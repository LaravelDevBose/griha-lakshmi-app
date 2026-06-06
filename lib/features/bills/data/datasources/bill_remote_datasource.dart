import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/bill_action_response_model.dart';
import '../models/bill_response_model.dart';

class BillRemoteDataSource {
  BillRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BillResponseModel> getBills({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getBillsWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getBillsWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<BillResponseModel> _getBillsWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/bill_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allBills = data['bills'] ?? [];

    final int total = allBills.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedBills = startIndex >= total
        ? []
        : allBills.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    int upcomingBills = 0;
    int paidBills = 0;
    int overdueBills = 0;
    double expectedTotal = 0;

    for (final dynamic item in allBills) {
      if (item is Map<String, dynamic>) {
        final String status = item['status']?.toString().toLowerCase() ?? '';

        expectedTotal +=
            double.tryParse(item['expected_amount'].toString()) ?? 0;

        if (status == 'upcoming') {
          upcomingBills++;
        } else if (status == 'paid') {
          paidBills++;
        } else if (status == 'overdue') {
          overdueBills++;
        }
      }
    }

    return BillResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_bills': total,
          'upcoming_bills': upcomingBills,
          'paid_bills': paidBills,
          'overdue_bills': overdueBills,
          'expected_total': expectedTotal,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'bills': paginatedBills,
      },
    });
  }

  Future<BillResponseModel> _getBillsWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.bills}?page=$page&per_page=$perPage';

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

    return BillResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<BillActionResponseModel> storeBill({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return BillActionResponseModel.fromJson({
        'success': true,
        'message': 'Bill saved successfully',
        'status_code': 201,
        'code': 'BILL_CREATED',
        'data': {
          'bill': {
            'id': DateTime.now().millisecondsSinceEpoch,
            ...payload,
            'status': payload['status'] ?? 'upcoming',
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeBill,
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

    return BillActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<BillActionResponseModel> updateBill({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return BillActionResponseModel.fromJson({
        'success': true,
        'message': 'Bill updated successfully',
        'status_code': 200,
        'code': 'BILL_UPDATED',
        'data': {
          'bill': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateBill(id),
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

    return BillActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<BillActionResponseModel> markBillPaid({
    required int id,
    required double paidAmount,
    required String paymentAccount,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return BillActionResponseModel.fromJson({
        'success': true,
        'message': 'Bill marked as paid and expense created',
        'status_code': 200,
        'code': 'BILL_PAID',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.markBillPaid(id),
      token: token,
      body: {
        'paid_amount': paidAmount,
        'payment_account': paymentAccount,
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

    return BillActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<BillActionResponseModel> snoozeBill({
    required int id,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));

      return BillActionResponseModel.fromJson({
        'success': true,
        'message': 'Bill reminder snoozed successfully',
        'status_code': 200,
        'code': 'BILL_SNOOZED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.snoozeBillReminder(id),
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

    return BillActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}