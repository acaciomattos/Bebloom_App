import 'package:flutter_test/flutter_test.dart';

import 'package:english_tutor_demo/shared/models/course_content.dart';

void main() {
  test('parseCourseModules parses module, lesson, vocabulary, and exercise data', () {
    const json = '''
{
  "modules": [
    {
      "id": "foundations",
      "title": "Foundations",
      "description": "Core material",
      "level": "Beginner",
      "lessons": [
        {
          "id": "verb_to_be",
          "moduleId": "foundations",
          "title": "Verb to Be",
          "level": "Beginner",
          "skills": ["Grammar", "Speaking"],
          "objectives": ["Use am, is, are"],
          "explanation": "Basic explanation",
          "examples": ["I am ready."],
          "vocabulary": [
            {
              "id": "word_1",
              "word": "ready",
              "translation": "pronto",
              "example": "I am ready.",
              "lessonId": "verb_to_be"
            }
          ],
          "exercises": [
            {
              "id": "exercise_1",
              "type": "multipleChoice",
              "question": "Choose one",
              "options": ["I am", "I is"],
              "correctAnswer": "I am",
              "feedback": "Use am with I.",
              "skill": "Grammar"
            }
          ]
        }
      ]
    }
  ]
}
''';

    final modules = parseCourseModules(json);

    expect(modules, hasLength(1));
    expect(modules.first.id, 'foundations');
    expect(modules.first.level, LessonLevel.beginner);
    expect(modules.first.lessons, hasLength(1));
    expect(modules.first.lessons.first.skills, [SkillTag.grammar, SkillTag.speaking]);
    expect(modules.first.lessons.first.vocabulary.first.word, 'ready');
    expect(
      modules.first.lessons.first.exercises.first.type,
      ExerciseType.multipleChoice,
    );
  });
}

