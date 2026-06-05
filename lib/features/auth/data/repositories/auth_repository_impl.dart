import '../../../../core/auth/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final loginResponse = await _remoteDataSource.login(
      LoginRequestModel(
        emailOrPhone: emailOrPhone,
        password: password,
      ),
    );

    final AuthSession session = loginResponse.toEntity();

    await TokenStorage.saveAuthSession(
      token: session.token,
      user: loginResponse.user.toJson(),
      family: loginResponse.family?.toJson(),
    );

    return session;
  }
}