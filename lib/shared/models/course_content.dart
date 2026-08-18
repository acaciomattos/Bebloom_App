import 'dart:convert';

enum LessonLevel {
  beginner('Beginner'),
  elementary('Elementary'),
  intermediate('Intermediate');

  const LessonLevel(this.label);

  final String label;

  static LessonLevel fromJson(String value) {
    return LessonLevel.values.firstWhere(
      (level) => level.label.toLowerCase() == value.toLowerCase(),
      orElse: () => LessonLevel.beginner,
    );
  }
}

enum SkillTag {
  grammar('Grammar'),
  vocabulary('Vocabulary'),
  speaking('Speaking'),
  listening('Listening'),
  reading('Reading');

  const SkillTag(this.label);

  final String label;

  static SkillTag fromJson(String value) {
    return SkillTag.values.firstWhere(
      (skill) => skill.label.toLowerCase() == value.toLowerCase(),
      orElse: () => SkillTag.reading,
    );
  }
}

enum ExerciseType {
  multipleChoice('multipleChoice'),
  fillBlank('fillBlank'),
  openQuestion('openQuestion');

  const ExerciseType(this.value);

  final String value;

  static ExerciseType fromJson(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ExerciseType.multipleChoice,
    );
  }
}

class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final LessonLevel level;
  final List<Lesson> lessons;

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: LessonLevel.fromJson(json['level'] as String),
      lessons: (json['lessons'] as List<dynamic>)
          .map((lesson) => Lesson.fromJson(lesson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.level,
    required this.skills,
    required this.objectives,
    required this.explanation,
    required this.examples,
    required this.vocabulary,
    required this.exercises,
  });

  final String id;
  final String moduleId;
  final String title;
  final LessonLevel level;
  final List<SkillTag> skills;
  final List<String> objectives;
  final String explanation;
  final List<String> examples;
  final List<VocabularyItem> vocabulary;
  final List<Exercise> exercises;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      level: LessonLevel.fromJson(json['level'] as String),
      skills: (json['skills'] as List<dynamic>)
          .map((item) => SkillTag.fromJson(item as String))
          .toList(),
      objectives: List<String>.from(json['objectives'] as List<dynamic>),
      explanation: json['explanation'] as String,
      examples: List<String>.from(json['examples'] as List<dynamic>),
      vocabulary: (json['vocabulary'] as List<dynamic>)
          .map(
            (item) => VocabularyItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.lessonId,
  });

  final String id;
  final String word;
  final String translation;
  final String example;
  final String lessonId;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      example: json['example'] as String,
      lessonId: json['lessonId'] as String,
    );
  }
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.feedback,
    required this.skill,
    required this.acceptedAnswers,
  });

  final String id;
  final ExerciseType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String feedback;
  final SkillTag skill;
  final List<String> acceptedAnswers;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      type: ExerciseType.fromJson(json['type'] as String),
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>? ?? const []),
      correctAnswer: json['correctAnswer'] as String,
      feedback: json['feedback'] as String,
      skill: SkillTag.fromJson(json['skill'] as String),
      acceptedAnswers: List<String>.from(
        json['acceptedAnswers'] as List<dynamic>? ?? const [],
      ),
    );
  }
}

List<CourseModule> parseCourseModules(String jsonString) {
  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  final modules = decoded['modules'] as List<dynamic>? ?? const [];
  return modules
      .map((module) => CourseModule.fromJson(module as Map<String, dynamic>))
      .toList();
}

