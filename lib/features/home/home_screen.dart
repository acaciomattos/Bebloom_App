import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/avatar_placeholder.dart';
import '../../shared/widgets/progress_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onContinueStudy,
    required this.onOpenLibrary,
    required this.onOpenProgress,
  });

  final VoidCallback onContinueStudy;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final continueLesson = controller.continueLesson;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF082F49), Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AvatarPlaceholder(size: 76),
              const SizedBox(height: 16),
              Text(
                'Ola! Vamos estudar ingles hoje?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                continueLesson != null
                    ? 'Sua proxima aula sugerida e ${continueLesson.title}.'
                    : 'Sua biblioteca esta pronta para comecar.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFE2E8F0),
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: continueLesson == null ? null : onContinueStudy,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                ),
                child: const Text('Continuar estudando'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ProgressCard(
                title: 'Aulas concluidas',
                value:
                    '${controller.completedLessonsCount}/${controller.allLessons.length}',
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProgressCard(
                title: 'Exercicios',
                value: '${controller.answeredExercisesCount}',
                subtitle: '${controller.correctAnswersCount} acertos',
                icon: Icons.quiz_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atalhos rapidos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.menu_book_rounded),
                  ),
                title: const Text('Biblioteca de aulas'),
                subtitle: const Text('Veja modulos, niveis e habilidades.'),
                trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onOpenLibrary,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.insights_rounded),
                  ),
                  title: const Text('Progresso'),
                  subtitle: const Text('Acompanhe conclusao e acertos.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onOpenProgress,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.smart_toy_outlined, color: Color(0xFF0284C7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'O avatar desta demo e apenas um placeholder visual. A estrutura foi deixada simples para trocar por um avatar real depois.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
