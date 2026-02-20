import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/exercise.dart';

/// 운동 타일 위젯
class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final bool showCategory;
  final bool showDifficulty;

  const ExerciseTile({
    super.key,
    required this.exercise,
    this.onTap,
    this.showCategory = true,
    this.showDifficulty = true,
  });

  Color get _categoryColor {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return AppColors.amrap;
      case ExerciseCategory.weightlifting:
        return AppColors.forTime;
      case ExerciseCategory.cardio:
        return AppColors.emom;
      case ExerciseCategory.monostructural:
        return AppColors.tabata;
    }
  }

  String get _categoryLabel {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return '체조';
      case ExerciseCategory.weightlifting:
        return '역도';
      case ExerciseCategory.cardio:
        return '유산소';
      case ExerciseCategory.monostructural:
        return '단일구조';
    }
  }

  IconData get _categoryIcon {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return Icons.accessibility_new;
      case ExerciseCategory.weightlifting:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      case ExerciseCategory.monostructural:
        return Icons.repeat;
    }
  }

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        return AppColors.beginner;
      case Difficulty.intermediate:
        return AppColors.intermediate;
      case Difficulty.advanced:
        return AppColors.advanced;
    }
  }

  String get _difficultyLabel {
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '상급';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _categoryIcon,
                color: _categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // 운동 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (showCategory) ...[
                        _CategoryBadge(
                          label: _categoryLabel,
                          color: _categoryColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (showDifficulty)
                        _DifficultyBadge(
                          label: _difficultyLabel,
                          color: _difficultyColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _DifficultyBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// WOD에서 사용되는 운동 타일
class WodExerciseTile extends StatelessWidget {
  final WodExercise wodExercise;
  final int index;
  final bool isActive;
  final VoidCallback? onTap;

  const WodExerciseTile({
    super.key,
    required this.wodExercise,
    required this.index,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // 순번
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 운동 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wodExercise.exercise.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wodExercise.displayText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 정보 아이콘
            if (onTap != null)
              Icon(
                Icons.info_outline,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
