import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/progress_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.onOpenLibrary});

  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final topics = controller.studiedTopics;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: ProgressCard(
                title: 'Conclusao geral',
                value: controller.completionPercentageLabel,
                subtitle:
                    '${controller.completedLessonsCount} aulas concluidas',
                icon: Icons.flag_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProgressCard(
                title: 'Acertos',
                value: '${controller.correctAnswersCount}',
                subtitle:
                    '${controller.answeredExercisesCount} respostas enviadas',
                icon: Icons.emoji_events_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ProgressCard(
          title: 'Ultimo modulo acessado',
          value: controller.lastOpenedModuleTitle ?? 'Ainda nao iniciado',
          subtitle: controller.lastOpenedLessonTitle ?? 'Sem aula recente',
          icon: Icons.history_edu_rounded,
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topicos estudados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                if (topics.isEmpty)
                  const Text(
                    'Os topicos aparecerao aqui conforme o aluno abrir aulas, responder exercicios e concluir conteudos.',
                  )
                else
                  ...topics.map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(topic)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onOpenLibrary,
                  child: const Text('Ir para a biblioteca'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
