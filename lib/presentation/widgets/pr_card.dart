import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/personal_record.dart';

/// PR 카드 위젯
class PrCard extends StatelessWidget {
  final PersonalRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isCompact;

  const PrCard({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _CompactPrCard(
        record: record,
        onTap: onTap,
      );
    }

    return _FullPrCard(
      record: record,
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}

class _FullPrCard extends StatelessWidget {
  final PersonalRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _FullPrCard({
    required this.record,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.exerciseName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (record.variation != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            record.variation!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.displayValue,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.displayDate,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Notes
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.note,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
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
}

class _CompactPrCard extends StatelessWidget {
  final PersonalRecord record;
  final VoidCallback? onTap;

  const _CompactPrCard({
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.exerciseName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (record.variation != null)
                    Text(
                      record.variation!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // 값
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.displayValue,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  record.displayDate,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
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

/// PR 입력 다이얼로그
class PrInputDialog extends StatefulWidget {
  final String? initialExercise;
  final String? initialVariation;
  final void Function(String exercise, double value, PrUnit unit, String? variation, String? notes) onSave;

  const PrInputDialog({
    super.key,
    this.initialExercise,
    this.initialVariation,
    required this.onSave,
  });

  @override
  State<PrInputDialog> createState() => _PrInputDialogState();
}

class _PrInputDialogState extends State<PrInputDialog> {
  late TextEditingController _exerciseController;
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  String? _selectedVariation;
  PrUnit _selectedUnit = PrUnit.lb;

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController(text: widget.initialExercise);
    _valueController = TextEditingController();
    _notesController = TextEditingController();
    _selectedVariation = widget.initialVariation;
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새 PR 기록',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 운동 이름
            TextField(
              controller: _exerciseController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '운동 이름',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // 변형
            DropdownButtonFormField<String>(
              initialValue: _selectedVariation,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '기록 유형',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              items: ['1RM', '2RM', '3RM', '5RM', 'Max Unbroken', 'Max Reps', 'Best Time']
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVariation = value;
                  if (value == 'Best Time') {
                    _selectedUnit = PrUnit.seconds;
                  } else if (value == 'Max Reps' || value == 'Max Unbroken') {
                    _selectedUnit = PrUnit.reps;
                  } else {
                    _selectedUnit = PrUnit.lb;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // 값 & 단위
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: '기록',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PrUnit>(
                    initialValue: _selectedUnit,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: '단위',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    items: PrUnit.values
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 메모
            TextField(
              controller: _notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final exercise = _exerciseController.text.trim();
    final valueText = _valueController.text.trim();
    final notes = _notesController.text.trim();

    if (exercise.isEmpty || valueText.isEmpty) {
      return;
    }

    final value = double.tryParse(valueText);
    if (value == null) {
      return;
    }

    widget.onSave(
      exercise,
      value,
      _selectedUnit,
      _selectedVariation,
      notes.isEmpty ? null : notes,
    );

    Navigator.of(context).pop();
  }
}
