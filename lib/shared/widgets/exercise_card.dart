import 'package:flutter/material.dart';

import '../models/course_content.dart';
import 'tag_chip.dart';

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onSubmit,
    this.previousResult,
  });

  final Exercise exercise;
  final Future<bool> Function(String answer) onSubmit;
  final bool? previousResult;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedOption;
  bool _isSubmitting = false;
  bool? _result;
  bool _submittedHere = false;

  @override
  void initState() {
    super.initState();
    _result = widget.previousResult;
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_submittedHere && widget.previousResult != oldWidget.previousResult) {
      _result = widget.previousResult;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final answer = widget.exercise.type == ExerciseType.multipleChoice
        ? (_selectedOption ?? '')
        : _controller.text;

    if (answer.trim().isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await widget.onSubmit(answer);
    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _submittedHere = true;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: ValueKey(widget.exercise.id),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TagChip(label: widget.exercise.skill.label),
                TagChip(
                  label: _labelForType(widget.exercise.type),
                  backgroundColor: const Color(0xFFDCFCE7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.exercise.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInput(),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: Text(
                _isSubmitting ? 'Checking...' : 'Check answer',
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result!
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result! ? 'Correct' : 'Try reviewing this point',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _result!
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.exercise.feedback,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _result!
                            ? const Color(0xFF166534)
                            : const Color(0xFF7F1D1D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    switch (widget.exercise.type) {
      case ExerciseType.multipleChoice:
        return Column(
          children: widget.exercise.options.map((option) {
            final isSelected = _selectedOption == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selectedOption = option),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE0F2FE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      case ExerciseType.fillBlank:
        return TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Type the missing word',
          ),
        );
      case ExerciseType.openQuestion:
        return TextField(
          controller: _controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a short answer',
          ),
        );
    }
  }

  String _labelForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.multipleChoice:
        return 'Multiple choice';
      case ExerciseType.fillBlank:
        return 'Fill blank';
      case ExerciseType.openQuestion:
        return 'Open question';
    }
  }
}
