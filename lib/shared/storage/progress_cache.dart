import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_progress.dart';

abstract class ProgressCache {
  Future<StudentProgress?> read();

  Future<void> write(StudentProgress progress);
}

class SharedPreferencesProgressCache implements ProgressCache {
  static const _progressKey = 'student_progress_v1';

  @override
  Future<StudentProgress?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StudentProgress.fromJson(decoded);
  }

  @override
  Future<void> write(StudentProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }
}
