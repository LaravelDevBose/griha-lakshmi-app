import '../../domain/entities/auth_session.dart';
import 'family_model.dart';
import 'user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.user,
    this.family,
    required this.message,
  });

  final String token;
  final UserModel user;
  final FamilyModel? family;
  final String message;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response data.');
    }

    final dynamic userJson = data['user'];

    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid user data.');
    }

    final dynamic familyJson = data['family'];

    return LoginResponseModel(
      token: data['token']?.toString() ?? '',
      user: UserModel.fromJson(userJson),
      family: familyJson is Map<String, dynamic>
          ? FamilyModel.fromJson(familyJson)
          : null,
      message: json['message']?.toString() ?? 'Login successful.',
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      user: user.toEntity(),
      family: family?.toEntity(),
    );
  }
}