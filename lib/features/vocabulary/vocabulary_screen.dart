import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/models/course_content.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key, required this.onOpenLesson});

  final Future<void> Function(Lesson lesson) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final savedItems = controller.savedVocabularyItems;

    if (savedItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nenhuma palavra salva ainda. Abra uma aula e toque no icone de salvar para montar seu vocabulario pessoal.',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: savedItems.length,
      itemBuilder: (context, index) {
        final item = savedItems[index];
        final lesson = controller.getLessonById(item.lessonId);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.word,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.toggleSavedVocabulary(item.id),
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ],
                ),
                Text(
                  item.translation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.example,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                ),
                if (lesson != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => onOpenLesson(lesson),
                    child: Text('Ver aula de origem: ${lesson.title}'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
