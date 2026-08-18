import 'package:flutter/material.dart';

import '../models/course_content.dart';
import 'tag_chip.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                    ),
                ],
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
              Text(
                lesson.explanation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onTap,
                child: Text(isCompleted ? 'Revisar aula' : 'Abrir aula'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

