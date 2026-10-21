import 'package:flutter_test/flutter_test.dart';

import 'package:english_tutor_demo/app.dart';
import 'package:english_tutor_demo/shared/models/student_progress.dart';
import 'package:english_tutor_demo/shared/repositories/student_progress_repository.dart';
import 'package:english_tutor_demo/shared/services/app_controller.dart';
import 'package:english_tutor_demo/shared/services/content_service.dart';

class _FakeContentService extends ContentService {}

class _FakeStudentProgressRepository implements StudentProgressRepository {
  @override
  Future<StudentProgress> load() async {
    return StudentProgress.initial();
  }

  @override
  Future<void> save(StudentProgress progress) async {}
}

void main() {
  testWidgets('renders the main shell', (tester) async {
    final controller = AppController(
      contentService: _FakeContentService(),
      progressRepository: _FakeStudentProgressRepository(),
    );

    await tester.pumpWidget(EnglishTutorDemoApp(controller: controller));
    await tester.pump();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
  });
}
