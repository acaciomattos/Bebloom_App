import 'package:flutter/foundation.dart';

import '../../features/exercises/exercise_evaluator.dart';
import '../models/course_content.dart';
import '../models/student_progress.dart';
import '../repositories/student_progress_repository.dart';
import 'content_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required ContentService contentService,
    required StudentProgressRepository progressRepository,
  })  : _contentService = contentService,
        _progressRepository = progressRepository;

  final ContentService _contentService;
  final StudentProgressRepository _progressRepository;

  List<CourseModule> _modules = const [];
  StudentProgress _progress = StudentProgress.initial();

  static Future<AppController> bootstrap({
    required StudentProgressRepository progressRepository,
  }) async {
    final controller = AppController(
      contentService: const ContentService(),
      progressRepository: progressRepository,
    );
    await controller._initialize();
    return controller;
  }

  Future<void> _initialize() async {
    _modules = await _contentService.loadModules();
    _progress = await _progressRepository.load();
  }

  List<CourseModule> get modules => _modules;

  StudentProgress get progress => _progress;

  List<Lesson> get allLessons =>
      _modules.expand((module) => module.lessons).toList(growable: false);

  List<VocabularyItem> get allVocabulary => allLessons
      .expand((lesson) => lesson.vocabulary)
      .toList(growable: false);

  Lesson? getLessonById(String lessonId) {
    for (final lesson in allLessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }

  CourseModule? getModuleById(String moduleId) {
    for (final module in _modules) {
      if (module.id == moduleId) {
        return module;
      }
    }
    return null;
  }

  Lesson? get continueLesson {
    final lastLessonId = _progress.lastOpenedLessonId;
    if (lastLessonId != null) {
      return getLessonById(lastLessonId);
    }

    for (final lesson in allLessons) {
      if (!_progress.completedLessonIds.contains(lesson.id)) {
        return lesson;
      }
    }

    return allLessons.isNotEmpty ? allLessons.first : null;
  }

  double get completionRate {
    if (allLessons.isEmpty) {
      return 0;
    }
    return _progress.completedLessonIds.length / allLessons.length;
  }

  int get completedLessonsCount => _progress.completedLessonIds.length;

  int get answeredExercisesCount => _progress.answeredExercisesCount;

  int get correctAnswersCount => _progress.correctAnswersCount;

  String get completionPercentageLabel =>
      '${(completionRate * 100).round()}%';

  String? get lastOpenedModuleTitle {
    final lessonId = _progress.lastOpenedLessonId;
    if (lessonId == null) {
      return null;
    }
    final lesson = getLessonById(lessonId);
    if (lesson == null) {
      return null;
    }
    return getModuleById(lesson.moduleId)?.title;
  }

  String? get lastOpenedLessonTitle {
    final lessonId = _progress.lastOpenedLessonId;
    if (lessonId == null) {
      return null;
    }
    return getLessonById(lessonId)?.title;
  }

  List<String> get studiedTopics {
    final lessonIds = <String>{
      ..._progress.completedLessonIds,
      if (_progress.lastOpenedLessonId != null) _progress.lastOpenedLessonId!,
      ...allLessons
          .where(
            (lesson) => lesson.exercises.any(
              (exercise) => _progress.exerciseResults.containsKey(exercise.id),
            ),
          )
          .map((lesson) => lesson.id),
    };

    return allLessons
        .where((lesson) => lessonIds.contains(lesson.id))
        .map((lesson) => lesson.title)
        .toList(growable: false);
  }

  List<VocabularyItem> get savedVocabularyItems {
    return allVocabulary
        .where((item) => _progress.savedVocabularyIds.contains(item.id))
        .toList(growable: false);
  }

  bool isLessonCompleted(String lessonId) {
    return _progress.completedLessonIds.contains(lessonId);
  }

  bool isVocabularySaved(String vocabularyId) {
    return _progress.savedVocabularyIds.contains(vocabularyId);
  }

  bool? getExerciseResult(String exerciseId) {
    return _progress.exerciseResults[exerciseId];
  }

  Future<void> registerLessonOpened(String lessonId) async {
    _progress = _progress.copyWith(lastOpenedLessonId: lessonId);
    await _persistProgress();
    notifyListeners();
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final updated = {..._progress.completedLessonIds, lessonId};
    _progress = _progress.copyWith(completedLessonIds: updated);
    await _persistProgress();
    notifyListeners();
  }

  Future<void> toggleSavedVocabulary(String vocabularyId) async {
    final updated = {..._progress.savedVocabularyIds};
    if (!updated.add(vocabularyId)) {
      updated.remove(vocabularyId);
    }
    _progress = _progress.copyWith(savedVocabularyIds: updated);
    await _persistProgress();
    notifyListeners();
  }

  Future<bool> submitExerciseAnswer(Exercise exercise, String answer) async {
    final result = ExerciseEvaluator.isCorrect(exercise, answer);
    final updatedResults = {..._progress.exerciseResults, exercise.id: result};
    _progress = _progress.copyWith(exerciseResults: updatedResults);
    await _persistProgress();
    notifyListeners();
    return result;
  }

  Future<void> resetProgress() async {
    _progress = StudentProgress.initial();
    await _persistProgress();
    notifyListeners();
  }

  Future<void> _persistProgress() async {
    await _progressRepository.save(_progress);
  }
}
