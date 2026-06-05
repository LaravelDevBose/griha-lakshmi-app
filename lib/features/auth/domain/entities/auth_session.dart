import 'auth_family.dart';
import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    this.family,
  });

  final String token;
  final AuthUser user;
  final AuthFamily? family;
}