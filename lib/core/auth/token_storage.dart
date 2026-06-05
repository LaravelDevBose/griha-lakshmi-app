import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_constants.dart';

class TokenStorage {
  TokenStorage._();

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppConstants.tokenKey,
      token,
    );
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<bool> hasToken() async {
    final String? token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConstants.tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppConstants.userKey,
      jsonEncode(userData),
    );
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? userJson = prefs.getString(AppConstants.userKey);

    if (userJson == null || userJson.trim().isEmpty) {
      return null;
    }

    final dynamic decodedUser = jsonDecode(userJson);

    if (decodedUser is Map<String, dynamic>) {
      return decodedUser;
    }

    return null;
  }

  static Future<void> saveFamilyData(Map<String, dynamic> familyData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppConstants.familyKey,
      jsonEncode(familyData),
    );
  }

  static Future<Map<String, dynamic>?> getFamilyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? familyJson = prefs.getString(AppConstants.familyKey);

    if (familyJson == null || familyJson.trim().isEmpty) {
      return null;
    }

    final dynamic decodedFamily = jsonDecode(familyJson);

    if (decodedFamily is Map<String, dynamic>) {
      return decodedFamily;
    }

    return null;
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(AppConstants.tokenKey),
      prefs.remove(AppConstants.userKey),
      prefs.remove(AppConstants.familyKey),
    ]);
  }

  static Future<bool> isLoggedIn() async {
    return hasToken();
  }
}