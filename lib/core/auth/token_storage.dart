import '../../app/app_constants.dart';
import '../cache/cache.dart';

class TokenStorage {
  TokenStorage._();

  static Future<void> saveToken(String token) async {
    await SecureStorage.saveToken(
      AppConstants.tokenKey,
      token,
    );
  }

  static Future<String?> getToken() async {
    return SecureStorage.getToken(AppConstants.tokenKey);
  }

  static Future<bool> hasToken() async {
    final String? token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> removeToken() async {
    await SecureStorage.removeToken(AppConstants.tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await LocalStorage.saveMap(
      key: AppConstants.userKey,
      value: userData,
    );
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    return LocalStorage.getMap(AppConstants.userKey);
  }

  static Future<void> saveFamilyData(Map<String, dynamic> familyData) async {
    await LocalStorage.saveMap(
      key: AppConstants.familyKey,
      value: familyData,
    );
  }

  static Future<Map<String, dynamic>?> getFamilyData() async {
    return LocalStorage.getMap(AppConstants.familyKey);
  }

  static Future<void> saveAuthSession({
    required String token,
    required Map<String, dynamic> user,
    Map<String, dynamic>? family,
  }) async {
    await saveToken(token);
    await saveUserData(user);

    if (family != null) {
      await saveFamilyData(family);
    }
  }

  static Future<void> clearAuthSession() async {
    await Future.wait([
      SecureStorage.remove(AppConstants.tokenKey),
      LocalStorage.remove(AppConstants.userKey),
      LocalStorage.remove(AppConstants.familyKey),
    ]);
  }

  static Future<bool> isLoggedIn() async {
    return hasToken();
  }
}