import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/beep_service.dart';
import '../../data/models/wod.dart';
import '../../data/models/exercise.dart';
import '../../providers/timer_provider.dart';
import '../../providers/workout_history_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/exercise_tile.dart';

/// 타이머 화면
class TimerScreen extends ConsumerStatefulWidget {
  final Wod wod;

  const TimerScreen({
    super.key,
    required this.wod,
  });

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final BeepService _beepService = BeepService.instance;
  int _amrapRounds = 0;

  Color get _typeColor {
    switch (widget.wod.type) {
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
  void initState() {
    super.initState();
    _beepService.init();
    // 타이머 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerNotifier = ref.read(timerProvider.notifier);
      timerNotifier.initializeForWod(widget.wod);
      timerNotifier.setCallbacks(
        onRoundChange: (_) => _playBeep(),
        onPhaseChange: (state) => _onPhaseChange(state),
        onMinuteStart: (_) => _playHighBeep(),
        onWarning: (_) => _playTick(),
        onFinish: (_) => _playFinish(),
        onReadyBeep: (_) => _playTick(),
      );
    });
  }

  @override
  void dispose() {
    // 화면 나갈 때 타이머 정리
    ref.read(timerProvider.notifier).stop();
    super.dispose();
  }

  void _playBeep() {
    _beepService.playBeep();
  }

  void _playHighBeep() {
    _beepService.playHighBeep();
  }

  void _playTick() {
    _beepService.playBeep();
  }

  void _playFinish() {
    _beepService.playFinish();
  }

  void _onPhaseChange(TimerState state) {
    if (state.isResting) {
      _beepService.playLowBeep();
    } else {
      _beepService.playHighBeep();
    }
  }

  /// 타이머 시작 (AudioContext resume 포함)
  void _startTimer() {
    _beepService.resumeAudioContext();
    ref.read(timerProvider.notifier).start();
  }

  /// 타이머 재개 (AudioContext resume 포함)
  void _resumeTimer() {
    _beepService.resumeAudioContext();
    ref.read(timerProvider.notifier).resume();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final isReady = timerState.status == TimerStatus.ready;
    final showRestOverlay = (widget.wod.type == WodType.emom ||
                             widget.wod.type == WodType.tabata) &&
                            timerState.status == TimerStatus.running &&
                            timerState.isResting;

    return PopScope(
      canPop: true,  // 항상 뒤로가기 허용
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 뒤로가기 시 타이머 정리
          ref.read(timerProvider.notifier).stop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleExit(context, timerState),
          ),
          title: Text(widget.wod.type.displayName),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // 메인 콘텐츠
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 메인 타이머
                          TimerDisplay(
                            timerState: timerState,
                            wodType: widget.wod.type,
                          ),

                          const SizedBox(height: 32),

                          // AMRAP 라운드 카운터
                          if (widget.wod.type == WodType.amrap &&
                              timerState.status == TimerStatus.running)
                            _AmrapCounter(
                              rounds: _amrapRounds,
                              onIncrement: () {
                                setState(() => _amrapRounds++);
                                _playBeep();
                              },
                            ),

                          // 현재 운동 표시 (EMOM/Tabata에서 휴식 중이 아닐 때)
                          if ((widget.wod.type == WodType.emom ||
                              widget.wod.type == WodType.tabata) &&
                              !showRestOverlay)
                            _CurrentExercise(
                              wod: widget.wod,
                              currentIndex: timerState.currentExerciseIndex %
                                  widget.wod.exercises.length,
                              typeColor: _typeColor,
                            ),

                          // REST 표시 (EMOM/Tabata 휴식 중)
                          if (showRestOverlay)
                            _RestDisplay(
                              phaseRemainingSeconds: timerState.phaseRemainingSeconds,
                            ),

                          const SizedBox(height: 24),

                          // 운동 목록
                          _ExerciseList(
                            wod: widget.wod,
                            currentIndex: timerState.currentExerciseIndex %
                                widget.wod.exercises.length,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 컨트롤 버튼
                  _ControlButtons(
                    timerState: timerState,
                    wodType: widget.wod.type,
                    typeColor: _typeColor,
                    onStart: _startTimer,
                    onPause: () => ref.read(timerProvider.notifier).pause(),
                    onResume: _resumeTimer,
                    onStop: () => _handleStop(context),
                    onComplete: () => _handleComplete(context, timerState),
                  ),
                ],
              ),
            ),

            // Ready 카운트다운 오버레이
            if (isReady)
              _ReadyCountdownOverlay(
                countdown: timerState.readyCountdown,
                typeColor: _typeColor,
              ),
          ],
        ),
      ),
    );
  }

  void _handleExit(BuildContext context, TimerState timerState) {
    // 타이머 정리 후 즉시 뒤로가기
    ref.read(timerProvider.notifier).stop();
    Navigator.of(context).pop();
  }

  void _handleStop(BuildContext context) {
    ref.read(timerProvider.notifier).stop();
  }

  void _handleComplete(BuildContext context, TimerState timerState) async {
    ref.read(timerProvider.notifier).pause();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _CompletionDialog(
        wod: widget.wod,
        timerState: timerState,
        amrapRounds: _amrapRounds,
      ),
    );

    if (result != null && mounted) {
      try {
        final historyNotifier = ref.read(workoutHistoryNotifierProvider.notifier);

        switch (widget.wod.type) {
          case WodType.amrap:
            await historyNotifier.saveAmrapResult(
              wod: widget.wod,
              rounds: result['rounds'] ?? _amrapRounds,
              extraReps: result['extraReps'] ?? 0,
              notes: result['notes'],
              isRx: result['isRx'] ?? true,
            );
            break;
          case WodType.forTime:
            await historyNotifier.saveForTimeResult(
              wod: widget.wod,
              completionTimeSeconds: timerState.elapsedSeconds,
              notes: result['notes'],
              isRx: result['isRx'] ?? true,
            );
            break;
          case WodType.emom:
          case WodType.tabata:
            await historyNotifier.saveCompletedResult(
              wod: widget.wod,
              notes: result['notes'],
              isRx: result['isRx'] ?? true,
            );
            break;
        }

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('운동 기록이 저장되었습니다!'),
              backgroundColor: AppColors.success,
            ),
          );
          navigator.popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('저장 실패: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

/// Ready 카운트다운 오버레이
class _ReadyCountdownOverlay extends StatelessWidget {
  final int countdown;
  final Color typeColor;

  const _ReadyCountdownOverlay({
    required this.countdown,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = countdown <= 5;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'READY',
              style: TextStyle(
                color: typeColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWarning
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : typeColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: isWarning ? AppColors.warning : typeColor,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$countdown',
                  style: TextStyle(
                    color: isWarning ? AppColors.warning : AppColors.textPrimary,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              '운동을 준비하세요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// REST 표시 위젯
class _RestDisplay extends StatelessWidget {
  final int phaseRemainingSeconds;

  const _RestDisplay({
    required this.phaseRemainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = phaseRemainingSeconds <= 5;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'REST',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$phaseRemainingSeconds',
              style: TextStyle(
                color: isWarning ? AppColors.warning : AppColors.textPrimary,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '휴식 중',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmrapCounter extends StatelessWidget {
  final int rounds;
  final VoidCallback onIncrement;

  const _AmrapCounter({
    required this.rounds,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onIncrement,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.amrap.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.amrap,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Text(
              '탭하여 라운드 추가',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.amrap,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '$rounds 라운드',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
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

class _CurrentExercise extends StatelessWidget {
  final Wod wod;
  final int currentIndex;
  final Color typeColor;

  const _CurrentExercise({
    required this.wod,
    required this.currentIndex,
    required this.typeColor,
  });

  IconData get _categoryIcon {
    switch (wod.exercises[currentIndex].exercise.category) {
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

  @override
  Widget build(BuildContext context) {
    final wodExercise = wod.exercises[currentIndex];
    final exercise = wodExercise.exercise;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '현재 운동',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // 운동 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _categoryIcon,
              size: 48,
              color: typeColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            exercise.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wodExercise.displayText,
            style: TextStyle(
              color: typeColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  final Wod wod;
  final int currentIndex;

  const _ExerciseList({
    required this.wod,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '운동 목록',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(wod.exercises.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WodExerciseTile(
              wodExercise: wod.exercises[index],
              index: index,
              isActive: index == currentIndex,
            ),
          );
        }),
      ],
    );
  }
}

class _ControlButtons extends StatelessWidget {
  final TimerState timerState;
  final WodType wodType;
  final Color typeColor;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onComplete;

  const _ControlButtons({
    required this.timerState,
    required this.wodType,
    required this.typeColor,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onComplete,
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
      child: Row(
        children: [
          // 정지 버튼 (ready 상태일 때는 메인 버튼에 취소가 있으므로 숨김)
          if ((timerState.status == TimerStatus.running ||
              timerState.status == TimerStatus.paused) &&
              timerState.status != TimerStatus.ready)
            Expanded(
              child: OutlinedButton(
                onPressed: onStop,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text(
                  '정지',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),

          if ((timerState.status == TimerStatus.running ||
              timerState.status == TimerStatus.paused) &&
              timerState.status != TimerStatus.ready)
            const SizedBox(width: 12),

          // 메인 버튼
          Expanded(
            flex: timerState.status == TimerStatus.ready ? 1 : 2,
            child: _buildMainButton(),
          ),

          // For Time 완료 버튼
          if (wodType == WodType.forTime &&
              timerState.status == TimerStatus.running) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('완료'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    switch (timerState.status) {
      case TimerStatus.initial:
        return ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: typeColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                '시작',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case TimerStatus.ready:
        return ElevatedButton(
          onPressed: onStop,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop, size: 28),
              SizedBox(width: 8),
              Text(
                '취소',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case TimerStatus.running:
        return ElevatedButton(
          onPressed: onPause,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause, size: 28),
              SizedBox(width: 8),
              Text(
                '일시정지',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case TimerStatus.paused:
        return ElevatedButton(
          onPressed: onResume,
          style: ElevatedButton.styleFrom(
            backgroundColor: typeColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                '계속하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case TimerStatus.finished:
        return ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 28),
              SizedBox(width: 8),
              Text(
                '기록 저장',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
    }
  }
}

class _CompletionDialog extends StatefulWidget {
  final Wod wod;
  final TimerState timerState;
  final int amrapRounds;

  const _CompletionDialog({
    required this.wod,
    required this.timerState,
    required this.amrapRounds,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  late TextEditingController _roundsController;
  late TextEditingController _extraRepsController;
  late TextEditingController _notesController;
  bool _isRx = true;

  @override
  void initState() {
    super.initState();
    _roundsController = TextEditingController(
      text: widget.amrapRounds.toString(),
    );
    _extraRepsController = TextEditingController(text: '0');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _roundsController.dispose();
    _extraRepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Row(
        children: [
          Icon(Icons.emoji_events, color: AppColors.warning),
          SizedBox(width: 12),
          Text(
            '운동 완료!',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수고하셨습니다! 결과를 기록해주세요.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // AMRAP 입력
            if (widget.wod.type == WodType.amrap) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _roundsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: '라운드',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _extraRepsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: '추가 횟수',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // For Time 결과
            if (widget.wod.type == WodType.forTime)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '완료 시간: ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      widget.timerState.elapsedTimeDisplay,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Rx 체크
            Row(
              children: [
                Checkbox(
                  value: _isRx,
                  onChanged: (value) {
                    setState(() => _isRx = value ?? true);
                  },
                  activeColor: AppColors.primary,
                ),
                const Text(
                  'Rx (처방대로 수행)',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 메모
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: '운동에 대한 메모를 남겨주세요',
                hintStyle: TextStyle(color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'rounds': int.tryParse(_roundsController.text) ?? widget.amrapRounds,
              'extraReps': int.tryParse(_extraRepsController.text) ?? 0,
              'notes': _notesController.text.isEmpty ? null : _notesController.text,
              'isRx': _isRx,
            });
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
