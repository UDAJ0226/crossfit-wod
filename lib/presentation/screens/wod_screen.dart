import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/wod.dart';
import '../widgets/exercise_tile.dart';
import 'timer_screen.dart';
import 'exercise_detail_screen.dart';

/// WOD 상세 화면
class WodScreen extends ConsumerWidget {
  final Wod wod;

  const WodScreen({
    super.key,
    required this.wod,
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(wod.type.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showWodInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WOD 헤더
                  _WodHeader(wod: wod, typeColor: _typeColor),

                  const SizedBox(height: 24),

                  // WOD 요약
                  _WodSummary(wod: wod, typeColor: _typeColor),

                  const SizedBox(height: 24),

                  // 운동 목록
                  const Text(
                    '운동 목록',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...List.generate(wod.exercises.length, (index) {
                    final wodExercise = wod.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WodExerciseTile(
                        wodExercise: wodExercise,
                        index: index,
                        onTap: () => _showExerciseDetail(
                          context,
                          wodExercise.exercise,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // 하단 시작 버튼
          _StartButton(
            wod: wod,
            typeColor: _typeColor,
            onStart: () => _startWorkout(context),
          ),
        ],
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimerScreen(wod: wod),
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  void _showWodInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wod.type.displayName,
                style: TextStyle(
                  color: _typeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wod.type.fullName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                wod.type.description,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              _buildWodTypeGuide(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWodTypeGuide() {
    switch (wod.type) {
      case WodType.amrap:
        return const _InfoItem(
          icon: Icons.timer,
          text: '제한 시간 내에 가능한 많은 라운드를 완료하세요.\n라운드 버튼을 눌러 라운드를 기록합니다.',
        );
      case WodType.emom:
        return const _InfoItem(
          icon: Icons.schedule,
          text: '매분 시작할 때 지정된 운동을 수행하세요.\n운동을 마친 후 남은 시간은 휴식입니다.',
        );
      case WodType.forTime:
        return const _InfoItem(
          icon: Icons.speed,
          text: '지정된 운동을 최대한 빠르게 완료하세요.\n완료 버튼을 눌러 시간을 기록합니다.',
        );
      case WodType.tabata:
        return const _InfoItem(
          icon: Icons.loop,
          text: '20초 운동, 10초 휴식을 8라운드 반복합니다.\n각 운동마다 8라운드씩 수행합니다.',
        );
    }
  }
}

class _WodHeader extends StatelessWidget {
  final Wod wod;
  final Color typeColor;

  const _WodHeader({
    required this.wod,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withValues(alpha: 0.3),
            typeColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${wod.duration}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wod.type.displayName,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wod.type.fullName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${wod.duration}분 | ${wod.exercises.length}개 운동',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WodSummary extends StatelessWidget {
  final Wod wod;
  final Color typeColor;

  const _WodSummary({
    required this.wod,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: typeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'WOD 설명',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            wod.summary,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            wod.type.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final Wod wod;
  final Color typeColor;
  final VoidCallback onStart;

  const _StartButton({
    required this.wod,
    required this.typeColor,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: typeColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 28),
                SizedBox(width: 8),
                Text(
                  '운동 시작',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
