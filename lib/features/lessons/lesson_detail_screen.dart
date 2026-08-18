import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/exercise_card.dart';
import '../../shared/widgets/tag_chip.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final lesson = controller.getLessonById(lessonId);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TagChip(
                        label: lesson.level.label,
                        backgroundColor: const Color(0xFFFDE68A),
                      ),
                      ...lesson.skills.map((skill) => TagChip(label: skill.label)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Objetivos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...lesson.objectives.map(
                    (objective) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(objective)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explicacao',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.explanation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF334155),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Exemplos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...lesson.examples.map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('- $example'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vocabulario relacionado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...lesson.vocabulary.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.word,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(item.translation),
                                const SizedBox(height: 6),
                                Text(
                                  item.example,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: () {
                              controller.toggleSavedVocabulary(item.id);
                            },
                            icon: Icon(
                              controller.isVocabularySaved(item.id)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_add_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Exercicios',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...lesson.exercises.map(
            (exercise) => ExerciseCard(
              exercise: exercise,
              previousResult: controller.getExerciseResult(exercise.id),
              onSubmit: (answer) => controller.submitExerciseAnswer(
                exercise,
                answer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: controller.isLessonCompleted(lesson.id)
                ? null
                : () => controller.markLessonCompleted(lesson.id),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              controller.isLessonCompleted(lesson.id)
                  ? 'Aula concluida'
                  : 'Marcar aula como concluida',
            ),
          ),
        ],
      ),
    );
  }
}
