import 'package:flutter/services.dart';

import '../models/course_content.dart';

class ContentService {
  const ContentService();

  Future<List<CourseModule>> loadModules() async {
    final content = await rootBundle.loadString('assets/content/lessons.json');
    return parseCourseModules(content);
  }
}

