import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/wod.dart';
import '../../providers/timer_provider.dart';

/// 대형 타이머 디스플레이
class TimerDisplay extends StatelessWidget {
  final TimerState timerState;
  final WodType wodType;
  final bool showProgress;

  const TimerDisplay({
    super.key,
    required this.timerState,
    required this.wodType,
    this.showProgress = true,
  });

  Color get _typeColor {
    switch (wodType) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 메인 타이머
        _MainTimer(
          timerState: timerState,
          wodType: wodType,
          color: _typeColor,
          showProgress: showProgress,
        ),

        const SizedBox(height: 16),

        // 추가 정보
        _buildAdditionalInfo(),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    switch (wodType) {
      case WodType.amrap:
        return _AmrapInfo(
          currentRound: timerState.currentRound,
          color: _typeColor,
        );
      case WodType.emom:
        return _EmomInfo(
          currentMinute: timerState.currentRound,
          totalMinutes: timerState.totalRounds,
          secondsInMinute: timerState.currentMinuteRemainingSeconds,
          color: _typeColor,
        );
      case WodType.forTime:
        return _ForTimeInfo(
          elapsedTime: timerState.elapsedTimeDisplay,
          color: _typeColor,
        );
      case WodType.tabata:
        return _TabataInfo(
          isWorkPhase: timerState.isWorkPhase,
          currentRound: timerState.currentRound,
          totalRounds: timerState.totalRounds,
          phaseSeconds: timerState.tabataPhaseRemainingSeconds,
          color: _typeColor,
        );
    }
  }
}

class _MainTimer extends StatelessWidget {
  final TimerState timerState;
  final WodType wodType;
  final Color color;
  final bool showProgress;

  const _MainTimer({
    required this.timerState,
    required this.wodType,
    required this.color,
    required this.showProgress,
  });

  String get _displayTime {
    switch (wodType) {
      case WodType.amrap:
      case WodType.emom:
      case WodType.tabata:
        return timerState.remainingTimeDisplay;
      case WodType.forTime:
        return timerState.elapsedTimeDisplay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 프로그레스 링
        if (showProgress)
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: wodType == WodType.forTime
                  ? timerState.progress
                  : 1 - timerState.progress,
              strokeWidth: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

        // 타이머 텍스트
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _displayTime,
              style: TextStyle(
                color: timerState.remainingSeconds <= 3 &&
                        timerState.status == TimerStatus.running
                    ? AppColors.error
                    : AppColors.textPrimary,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            if (wodType == WodType.forTime)
              Text(
                'Time Cap: ${timerState.totalSeconds ~/ 60}분',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AmrapInfo extends StatelessWidget {
  final int currentRound;
  final Color color;

  const _AmrapInfo({
    required this.currentRound,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.repeat,
            color: AppColors.textPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '현재 라운드: $currentRound',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmomInfo extends StatelessWidget {
  final int currentMinute;
  final int totalMinutes;
  final int secondsInMinute;
  final Color color;

  const _EmomInfo({
    required this.currentMinute,
    required this.totalMinutes,
    required this.secondsInMinute,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '분 $currentMinute / $totalMinutes',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '이번 분 남은 시간: $secondsInMinute초',
          style: TextStyle(
            color: secondsInMinute <= 10 ? AppColors.warning : AppColors.textSecondary,
            fontSize: 16,
            fontWeight: secondsInMinute <= 10 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ForTimeInfo extends StatelessWidget {
  final String elapsedTime;
  final Color color;

  const _ForTimeInfo({
    required this.elapsedTime,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      '최대한 빠르게 완료하세요!',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
    );
  }
}

class _TabataInfo extends StatelessWidget {
  final bool isWorkPhase;
  final int currentRound;
  final int totalRounds;
  final int phaseSeconds;
  final Color color;

  const _TabataInfo({
    required this.isWorkPhase,
    required this.currentRound,
    required this.totalRounds,
    required this.phaseSeconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 운동/휴식 표시
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            color: isWorkPhase
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWorkPhase ? AppColors.success : AppColors.error,
              width: 2,
            ),
          ),
          child: Text(
            isWorkPhase ? '운동!' : '휴식',
            style: TextStyle(
              color: isWorkPhase ? AppColors.success : AppColors.error,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 구간 타이머
        Text(
          '$phaseSeconds초',
          style: TextStyle(
            color: phaseSeconds <= 3 ? AppColors.warning : AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 라운드 정보
        Text(
          '라운드 $currentRound / $totalRounds',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// 컴팩트 타이머 디스플레이 (작은 화면용)
class TimerDisplayCompact extends StatelessWidget {
  final TimerState timerState;
  final WodType wodType;

  const TimerDisplayCompact({
    super.key,
    required this.timerState,
    required this.wodType,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            wodType == WodType.forTime
                ? timerState.elapsedTimeDisplay
                : timerState.remainingTimeDisplay,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (wodType == WodType.amrap)
            Text(
              'R${timerState.currentRound}',
              style: const TextStyle(
                color: AppColors.amrap,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (wodType == WodType.tabata)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timerState.isWorkPhase
                    ? AppColors.success
                    : AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timerState.isWorkPhase ? '운동' : '휴식',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
