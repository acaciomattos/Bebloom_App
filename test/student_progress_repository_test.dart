import 'package:flutter_test/flutter_test.dart';

import 'package:english_tutor_demo/shared/models/student_progress.dart';
import 'package:english_tutor_demo/shared/repositories/student_progress_repository.dart';
import 'package:english_tutor_demo/shared/storage/progress_cache.dart';

class _MemoryProgressCache implements ProgressCache {
  StudentProgress? storedProgress;

  @override
  Future<StudentProgress?> read() async => storedProgress;

  @override
  Future<void> write(StudentProgress progress) async {
    storedProgress = progress;
  }
}

void main() {
  test('returns an initial progress model when the cache is empty', () async {
    final repository = LocalStudentProgressRepository(
      cache: _MemoryProgressCache(),
    );

    final progress = await repository.load();

    expect(progress.completedLessonIds, isEmpty);
    expect(progress.exerciseResults, isEmpty);
    expect(progress.savedVocabularyIds, isEmpty);
    expect(progress.lastOpenedLessonId, isNull);
  });

  test('writes progress through the local cache', () async {
    final cache = _MemoryProgressCache();
    final repository = LocalStudentProgressRepository(cache: cache);
    const progress = StudentProgress(
      completedLessonIds: {'verb-to-be'},
      exerciseResults: {'verb-to-be-1': true},
      savedVocabularyIds: {'vocab-be-happy'},
      lastOpenedLessonId: 'verb-to-be',
    );

    await repository.save(progress);

    expect(cache.storedProgress?.completedLessonIds, {'verb-to-be'});
    expect(cache.storedProgress?.exerciseResults, {'verb-to-be-1': true});
    expect(cache.storedProgress?.savedVocabularyIds, {'vocab-be-happy'});
    expect(cache.storedProgress?.lastOpenedLessonId, 'verb-to-be');
  });
}
