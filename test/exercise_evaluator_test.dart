import 'package:flutter_test/flutter_test.dart';

import 'package:english_tutor_demo/features/exercises/exercise_evaluator.dart';
import 'package:english_tutor_demo/shared/models/course_content.dart';

void main() {
  group('ExerciseEvaluator', () {
    test('accepts matching multiple choice answers', () {
      const exercise = Exercise(
        id: 'mc_1',
        type: ExerciseType.multipleChoice,
        question: 'Choose',
        options: ['She is', 'She are'],
        correctAnswer: 'She is',
        feedback: 'Use is with she.',
        skill: SkillTag.grammar,
        acceptedAnswers: [],
      );

      expect(ExerciseEvaluator.isCorrect(exercise, 'She is'), isTrue);
      expect(ExerciseEvaluator.isCorrect(exercise, 'She are'), isFalse);
    });

    test('normalizes fill blank answers', () {
      const exercise = Exercise(
        id: 'fill_1',
        type: ExerciseType.fillBlank,
        question: 'Complete',
        options: [],
        correctAnswer: 'are',
        feedback: 'Use are with they.',
        skill: SkillTag.grammar,
        acceptedAnswers: ['are'],
      );

      expect(ExerciseEvaluator.isCorrect(exercise, '  ARE  '), isTrue);
    });

    test('accepts open answers that start with an approved phrase', () {
      const exercise = Exercise(
        id: 'open_1',
        type: ExerciseType.openQuestion,
        question: 'Introduce yourself',
        options: [],
        correctAnswer: 'i am',
        feedback: 'Start with I am.',
        skill: SkillTag.speaking,
        acceptedAnswers: ['i am', "i'm"],
      );

      expect(ExerciseEvaluator.isCorrect(exercise, 'I am Lucas.'), isTrue);
      expect(ExerciseEvaluator.isCorrect(exercise, "I'm Ana."), isTrue);
      expect(ExerciseEvaluator.isCorrect(exercise, 'My name Ana.'), isFalse);
    });
  });
}

