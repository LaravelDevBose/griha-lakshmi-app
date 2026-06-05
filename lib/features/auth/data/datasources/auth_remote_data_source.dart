import '../../../../app/app_config.dart';
import '../../../../core/api/api.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/mock/mock_loader.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    if (AppConfig.useMockData) {
      return _loginWithMockData(request);
    }

    return _loginWithApi(request);
  }

  Future<LoginResponseModel> _loginWithMockData(
    LoginRequestModel request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final bool isCorrectMockUser =
        request.emailOrPhone == '01700000000' &&
        request.password == '12345678';

    final Map<String, dynamic> response = await MockLoader.loadJson(
      isCorrectMockUser
          ? 'assets/mock/login_success.json'
          : 'assets/mock/login_error.json',
    );

    if (response['success'] != true) {
      throw Failure.fromJson(response);
    }

    return LoginResponseModel.fromJson(response);
  }

  Future<LoginResponseModel> _loginWithApi(
    LoginRequestModel request,
  ) async {
    final ApiResponse<Map<String, dynamic>> response =
        await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      body: request.toJson(),
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

    return LoginResponseModel.fromJson({
      'success': response.success,
      'message': response.message,
      'status_code': response.statusCode,
      'code': response.code,
      'data': response.data,
    });
  }
}