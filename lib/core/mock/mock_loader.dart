import 'dart:convert';

import 'package:flutter/services.dart';

class MockLoader {
  MockLoader._();

  static Future<Map<String, dynamic>> loadJson(String path) async {
    final String jsonString = await rootBundle.loadString(path);

    final dynamic decodedJson = jsonDecode(jsonString);

    if (decodedJson is Map<String, dynamic>) {
      return decodedJson;
    }

    throw const FormatException('Mock JSON must be an object.');
  }
}