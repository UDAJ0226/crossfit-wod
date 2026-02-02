import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../providers/wod_provider.dart';

/// 난이도 선택 위젯
class DifficultySelector extends ConsumerWidget {
  final void Function(Difficulty)? onChanged;

  const DifficultySelector({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Difficulty.values.map((difficulty) {
        final isSelected = difficulty == selectedDifficulty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _DifficultyChip(
            difficulty: difficulty,
            isSelected: isSelected,
            onTap: () {
              ref.read(selectedDifficultyProvider.notifier).state = difficulty;
              onChanged?.call(difficulty);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (difficulty) {
      case Difficulty.beginner:
        return AppColors.beginner;
      case Difficulty.intermediate:
        return AppColors.intermediate;
      case Difficulty.advanced:
        return AppColors.advanced;
    }
  }

  String get _label {
    switch (difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _color : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _color : AppColors.secondaryLight,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          _label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// 확장된 난이도 선택 위젯 (설명 포함)
class DifficultyCard extends ConsumerWidget {
  final void Function(Difficulty)? onChanged;

  const DifficultyCard({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '난이도 선택',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...Difficulty.values.map((difficulty) {
          final isSelected = difficulty == selectedDifficulty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DifficultyTile(
              difficulty: difficulty,
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedDifficultyProvider.notifier).state = difficulty;
                onChanged?.call(difficulty);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (difficulty) {
      case Difficulty.beginner:
        return AppColors.beginner;
      case Difficulty.intermediate:
        return AppColors.intermediate;
      case Difficulty.advanced:
        return AppColors.advanced;
    }
  }

  String get _label {
    switch (difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
    }
  }

  String get _description {
    switch (difficulty) {
      case Difficulty.beginner:
        return '기본 동작 위주, 낮은 강도';
      case Difficulty.intermediate:
        return '복합 동작 포함, 중간 강도';
      case Difficulty.advanced:
        return '고급 동작, 높은 강도';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _color : AppColors.secondaryLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _color : Colors.transparent,
                border: Border.all(
                  color: _color,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: TextStyle(
                      color: isSelected ? _color : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
