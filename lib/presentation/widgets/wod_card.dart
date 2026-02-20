import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/wod.dart';
import '../../data/models/exercise.dart';

/// WOD 카드 위젯
class WodCard extends StatelessWidget {
  final Wod wod;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final bool showStartButton;

  const WodCard({
    super.key,
    required this.wod,
    this.onTap,
    this.onStart,
    this.showStartButton = true,
  });

  Color get _typeColor {
    switch (wod.type) {
      case WodType.amrap:
        return AppColors.amrap;
      case WodType.emom:
        return AppColors.emom;
      case WodType.forTime:
        return AppColors.forTime;
      case WodType.tabata:
        return AppColors.tabata;
    }
  }

  Color get _difficultyColor {
    switch (wod.difficulty) {
      case Difficulty.beginner:
        return AppColors.beginner;
      case Difficulty.intermediate:
        return AppColors.intermediate;
      case Difficulty.advanced:
        return AppColors.advanced;
    }
  }

  String get _difficultyLabel {
    switch (wod.difficulty) {
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
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wod.type.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _difficultyColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _difficultyLabel,
                          style: TextStyle(
                            color: _difficultyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${wod.duration}분',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Body - 운동 목록
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WOD 요약
                  Text(
                    wod.summary,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 운동 목록
                  ...wod.exercises.map((wodExercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              wodExercise.displayText,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // 시작 버튼
                  if (showStartButton) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _typeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '운동 시작',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 WOD 카드 (리스트용)
class WodCardCompact extends StatelessWidget {
  final Wod wod;
  final VoidCallback? onTap;

  const WodCardCompact({
    super.key,
    required this.wod,
    this.onTap,
  });

  Color get _typeColor {
    switch (wod.type) {
      case WodType.amrap:
        return AppColors.amrap;
      case WodType.emom:
        return AppColors.emom;
      case WodType.forTime:
        return AppColors.forTime;
      case WodType.tabata:
        return AppColors.tabata;
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
          border: Border.all(
            color: _typeColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  wod.type.displayName.substring(0, 1),
                  style: TextStyle(
                    color: _typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${wod.type.displayName} ${wod.duration}분',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wod.exercises.length}개 운동',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
