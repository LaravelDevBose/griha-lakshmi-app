import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> save({
    required String key,
    required String value,
  }) async {
    await _storage.write(
      key: key,
      value: value,
    );
  }

  static Future<String?> get(String key) async {
    return _storage.read(key: key);
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<bool> containsKey(String key) async {
    final String? value = await get(key);

    return value != null && value.trim().isNotEmpty;
  }

  static Future<void> saveToken(String tokenKey, String token) async {
    await save(
      key: tokenKey,
      value: token,
    );
  }

  static Future<String?> getToken(String tokenKey) async {
    return get(tokenKey);
  }

  static Future<void> removeToken(String tokenKey) async {
    await remove(tokenKey);
  }
}