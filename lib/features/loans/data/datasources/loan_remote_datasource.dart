import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/loan_action_response_model.dart';
import '../models/loan_response_model.dart';

class LoanRemoteDataSource {
  LoanRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoanResponseModel> getLoans({
    required int page,
    required int perPage,
  }) async {
    if (AppConfig.useMockData) {
      return _getLoansWithMockData(
        page: page,
        perPage: perPage,
      );
    }

    return _getLoansWithApi(
      page: page,
      perPage: perPage,
    );
  }

  Future<LoanResponseModel> _getLoansWithMockData({
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/loan_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response['data'] ?? <String, dynamic>{});

    final List<dynamic> allLoans = data['loans'] ?? [];

    final int total = allLoans.length;
    final int lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final int startIndex = (page - 1) * perPage;
    final int endIndex = startIndex + perPage;

    final List<dynamic> paginatedLoans = startIndex >= total
        ? []
        : allLoans.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );

    int activeLoans = 0;
    int completedLoans = 0;
    double totalRemainingBalance = 0;
    double monthlyInstallmentTotal = 0;

    for (final dynamic item in allLoans) {
      if (item is Map<String, dynamic>) {
        final String status = item['status']?.toString().toLowerCase() ?? '';

        if (status == 'active') {
          activeLoans++;
        }

        if (status == 'completed') {
          completedLoans++;
        }

        totalRemainingBalance +=
            double.tryParse(item['remaining_balance'].toString()) ?? 0;

        if (status == 'active') {
          monthlyInstallmentTotal +=
              double.tryParse(item['installment_amount'].toString()) ?? 0;
        }
      }
    }

    return LoanResponseModel.fromJson({
      'success': response['success'],
      'message': response['message'],
      'status_code': response['status_code'],
      'code': response['code'],
      'data': {
        'summary': {
          'total_loans': total,
          'active_loans': activeLoans,
          'completed_loans': completedLoans,
          'total_remaining_balance': totalRemainingBalance,
          'monthly_installment_total': monthlyInstallmentTotal,
        },
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
        },
        'loans': paginatedLoans,
      },
    });
  }

  Future<LoanResponseModel> _getLoansWithApi({
    required int page,
    required int perPage,
  }) async {
    final String? token = await TokenStorage.getToken();

    final String endpoint =
        '${ApiEndpoints.loans}?page=$page&per_page=$perPage';

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

    return LoanResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<LoanActionResponseModel> storeLoan({
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return LoanActionResponseModel.fromJson({
        'success': true,
        'message': 'Loan saved successfully',
        'status_code': 201,
        'code': 'LOAN_CREATED',
        'data': {
          'loan': {
            'id': DateTime.now().millisecondsSinceEpoch,
            ...payload,
            'status': payload['status'] ?? 'active',
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.storeLoan,
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

    return LoanActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<LoanActionResponseModel> updateLoan({
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return LoanActionResponseModel.fromJson({
        'success': true,
        'message': 'Loan updated successfully',
        'status_code': 200,
        'code': 'LOAN_UPDATED',
        'data': {
          'loan': {
            'id': id,
            ...payload,
          },
        },
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateLoan(id),
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

    return LoanActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }

  Future<LoanActionResponseModel> recordPayment({
    required int id,
    required double paymentAmount,
    required String paymentAccount,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      return LoanActionResponseModel.fromJson({
        'success': true,
        'message': 'Loan payment recorded and expense created',
        'status_code': 200,
        'code': 'LOAN_PAYMENT_RECORDED',
        'data': null
      });
    }

    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recordLoanPayment(id),
      token: token,
      body: {
        'payment_amount': paymentAmount,
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

    return LoanActionResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}