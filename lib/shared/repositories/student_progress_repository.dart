import '../models/student_progress.dart';
import '../storage/progress_cache.dart';

abstract class StudentProgressRepository {
  Future<StudentProgress> load();

  Future<void> save(StudentProgress progress);
}

class LocalStudentProgressRepository implements StudentProgressRepository {
  const LocalStudentProgressRepository({required ProgressCache cache})
      : _cache = cache;

  final ProgressCache _cache;

  @override
  Future<StudentProgress> load() async {
    return await _cache.read() ?? StudentProgress.initial();
  }

  @override
  Future<void> save(StudentProgress progress) {
    return _cache.write(progress);
  }
}
