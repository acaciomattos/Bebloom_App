import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/models/course_content.dart';
import '../../shared/widgets/lesson_card.dart';

class LessonLibraryScreen extends StatefulWidget {
  const LessonLibraryScreen({super.key, required this.onOpenLesson});

  final Future<void> Function(Lesson lesson) onOpenLesson;

  @override
  State<LessonLibraryScreen> createState() => _LessonLibraryScreenState();
}

class _LessonLibraryScreenState extends State<LessonLibraryScreen> {
  LessonLevel? _selectedLevel;
  SkillTag? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Explore modulos e filtre por nivel ou habilidade.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569),
              ),
        ),
        const SizedBox(height: 16),
        _FilterSection(
          selectedLevel: _selectedLevel,
          selectedSkill: _selectedSkill,
          onLevelSelected: (level) => setState(() => _selectedLevel = level),
          onSkillSelected: (skill) => setState(() => _selectedSkill = skill),
        ),
        const SizedBox(height: 20),
        ...controller.modules.map((module) {
          final visibleLessons = module.lessons.where(_matchesFilters).toList();
          if (visibleLessons.isEmpty) {
            return const SizedBox.shrink();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    module.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...visibleLessons.map(
                    (lesson) => LessonCard(
                      lesson: lesson,
                      isCompleted: controller.isLessonCompleted(lesson.id),
                      onTap: () => widget.onOpenLesson(lesson),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _matchesFilters(Lesson lesson) {
    final levelMatch =
        _selectedLevel == null || lesson.level == _selectedLevel;
    final skillMatch =
        _selectedSkill == null || lesson.skills.contains(_selectedSkill);
    return levelMatch && skillMatch;
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.selectedLevel,
    required this.selectedSkill,
    required this.onLevelSelected,
    required this.onSkillSelected,
  });

  final LessonLevel? selectedLevel;
  final SkillTag? selectedSkill;
  final ValueChanged<LessonLevel?> onLevelSelected;
  final ValueChanged<SkillTag?> onSkillSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar por nivel',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: selectedLevel == null,
                  onSelected: (_) => onLevelSelected(null),
                ),
                ...LessonLevel.values.map(
                  (level) => ChoiceChip(
                    label: Text(level.label),
                    selected: selectedLevel == level,
                    onSelected: (_) => onLevelSelected(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Filtrar por habilidade',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: selectedSkill == null,
                  onSelected: (_) => onSkillSelected(null),
                ),
                ...SkillTag.values.map(
                  (skill) => ChoiceChip(
                    label: Text(skill.label),
                    selected: selectedSkill == skill,
                    onSelected: (_) => onSkillSelected(skill),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
