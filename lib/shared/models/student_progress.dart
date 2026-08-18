class StudentProgress {
  const StudentProgress({
    required this.completedLessonIds,
    required this.exerciseResults,
    required this.savedVocabularyIds,
    required this.lastOpenedLessonId,
  });

  final Set<String> completedLessonIds;
  final Map<String, bool> exerciseResults;
  final Set<String> savedVocabularyIds;
  final String? lastOpenedLessonId;

  factory StudentProgress.initial() {
    return const StudentProgress(
      completedLessonIds: <String>{},
      exerciseResults: <String, bool>{},
      savedVocabularyIds: <String>{},
      lastOpenedLessonId: null,
    );
  }

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    final rawResults = json['exerciseResults'] as Map<String, dynamic>? ?? {};
    return StudentProgress(
      completedLessonIds: Set<String>.from(
        json['completedLessonIds'] as List<dynamic>? ?? const [],
      ),
      exerciseResults: rawResults.map(
        (key, value) => MapEntry(key, value as bool),
      ),
      savedVocabularyIds: Set<String>.from(
        json['savedVocabularyIds'] as List<dynamic>? ?? const [],
      ),
      lastOpenedLessonId: json['lastOpenedLessonId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLessonIds': completedLessonIds.toList(),
      'exerciseResults': exerciseResults,
      'savedVocabularyIds': savedVocabularyIds.toList(),
      'lastOpenedLessonId': lastOpenedLessonId,
    };
  }

  int get answeredExercisesCount => exerciseResults.length;

  int get correctAnswersCount =>
      exerciseResults.values.where((result) => result).length;

  StudentProgress copyWith({
    Set<String>? completedLessonIds,
    Map<String, bool>? exerciseResults,
    Set<String>? savedVocabularyIds,
    String? lastOpenedLessonId,
    bool clearLastOpenedLesson = false,
  }) {
    return StudentProgress(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      exerciseResults: exerciseResults ?? this.exerciseResults,
      savedVocabularyIds: savedVocabularyIds ?? this.savedVocabularyIds,
      lastOpenedLessonId: clearLastOpenedLesson
          ? null
          : (lastOpenedLessonId ?? this.lastOpenedLessonId),
    );
  }
}
