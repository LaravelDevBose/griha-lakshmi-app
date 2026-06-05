import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardModel> getDashboard() async {
    if (AppConfig.useMockData) {
      return _getDashboardWithMockData();
    }

    return _getDashboardWithApi();
  }

  Future<DashboardModel> _getDashboardWithMockData() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final Map<String, dynamic> response = await MockLoader.loadJson(
      'assets/mock/dashboard_success.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    return DashboardModel.fromJson(response);
  }

  Future<DashboardModel> _getDashboardWithApi() async {
    final String? token = await TokenStorage.getToken();

    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.dashboard,
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

    return DashboardModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}