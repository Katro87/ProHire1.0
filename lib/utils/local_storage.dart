import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _webKey = '.prohire_data';

  Future<void> writeData(Map<String, dynamic> data) async {
    final String payload = jsonEncode(data);
    if (kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webKey, payload);
      return;
    }

    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/.prohire_data');
    await file.writeAsString(payload, flush: true);
  }

  Future<Map<String, dynamic>?> readData() async {
    try {
      if (kIsWeb) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? raw = prefs.getString(_webKey);
        if (raw == null || raw.isEmpty) {
          return null;
        }
        return jsonDecode(raw) as Map<String, dynamic>;
      }

      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/.prohire_data');
      if (!await file.exists()) {
        return null;
      }
      final String raw = await file.readAsString();
      if (raw.isEmpty) {
        return null;
      }
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
