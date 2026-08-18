import 'package:flutter/material.dart';

import 'app.dart';
import 'shared/services/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await AppController.bootstrap();
  runApp(EnglishTutorDemoApp(controller: controller));
}

