import 'package:flutter/material.dart';

import 'app.dart';
import 'shared/repositories/student_progress_repository.dart';
import 'shared/services/app_controller.dart';
import 'shared/storage/progress_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await AppController.bootstrap(
    progressRepository: LocalStudentProgressRepository(
      cache: SharedPreferencesProgressCache(),
    ),
  );
  runApp(EnglishTutorDemoApp(controller: controller));
}
