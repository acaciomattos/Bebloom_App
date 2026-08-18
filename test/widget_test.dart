import 'package:flutter_test/flutter_test.dart';

import 'package:english_tutor_demo/app.dart';
import 'package:english_tutor_demo/shared/services/app_controller.dart';
import 'package:english_tutor_demo/shared/services/content_service.dart';
import 'package:english_tutor_demo/shared/storage/progress_storage.dart';
import 'package:english_tutor_demo/shared/models/student_progress.dart';

class _FakeContentService extends ContentService {}

class _FakeProgressStorage implements ProgressStorage {
  @override
  Future<StudentProgress> loadProgress() async {
    return StudentProgress.initial();
  }

  @override
  Future<void> saveProgress(StudentProgress progress) async {}
}

void main() {
  testWidgets('renders the main shell', (tester) async {
    final controller = AppController(
      contentService: _FakeContentService(),
      progressStorage: _FakeProgressStorage(),
    );

    await tester.pumpWidget(EnglishTutorDemoApp(controller: controller));
    await tester.pump();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
  });
}
