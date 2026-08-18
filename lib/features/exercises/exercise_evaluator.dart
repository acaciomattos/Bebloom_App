import '../../shared/models/course_content.dart';

class ExerciseEvaluator {
  static bool isCorrect(Exercise exercise, String answer) {
    final normalizedAnswer = _normalize(answer);
    final accepted = <String>[
      exercise.correctAnswer,
      ...exercise.acceptedAnswers,
    ].map(_normalize).where((value) => value.isNotEmpty).toList();

    switch (exercise.type) {
      case ExerciseType.multipleChoice:
      case ExerciseType.fillBlank:
        return accepted.contains(normalizedAnswer);
      case ExerciseType.openQuestion:
        return accepted.any(
          (candidate) =>
              normalizedAnswer == candidate ||
              normalizedAnswer.startsWith('$candidate '),
        );
    }
  }

  static String _normalize(String value) {
    final compact = value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return compact.replaceAll(RegExp(r"[^a-z0-9\s']"), '');
  }
}
