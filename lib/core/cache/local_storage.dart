import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static Future<void> saveString({
    required String key,
    required String value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveInt({
    required String key,
    required int value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> saveDouble({
    required String key,
    required double value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> saveBool({
    required String key,
    required bool value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> saveStringList({
    required String key,
    required List<String> value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<void> saveMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(value),
    );
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? value = prefs.getString(key);

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final dynamic decodedValue = jsonDecode(value);

    if (decodedValue is Map<String, dynamic>) {
      return decodedValue;
    }

    return null;
  }

  static Future<void> saveListMap({
    required String key,
    required List<Map<String, dynamic>> value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(value),
    );
  }

  static Future<List<Map<String, dynamic>>> getListMap(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? value = prefs.getString(key);

    if (value == null || value.trim().isEmpty) {
      return [];
    }

    final dynamic decodedValue = jsonDecode(value);

    if (decodedValue is List) {
      return decodedValue
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<void> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}