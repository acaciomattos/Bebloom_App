import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_progress.dart';

abstract class ProgressStorage {
  Future<StudentProgress> loadProgress();

  Future<void> saveProgress(StudentProgress progress);
}

class SharedPreferencesProgressStorage implements ProgressStorage {
  static const _progressKey = 'student_progress_v1';

  @override
  Future<StudentProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return StudentProgress.initial();
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StudentProgress.fromJson(decoded);
  }

  @override
  Future<void> saveProgress(StudentProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }
}

