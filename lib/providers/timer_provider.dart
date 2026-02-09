import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/wod.dart';

/// 타이머 상태
enum TimerStatus {
  initial, // 초기 상태
  ready, // 준비 카운트다운 (10초)
  running, // 실행 중
  paused, // 일시정지
  finished, // 완료
}

/// 타이머 페이즈
enum TimerPhase {
  work, // 운동 중
  rest, // 휴식 중
}

/// 타이머 상태 클래스
class TimerState {
  final TimerStatus status;
  final int totalSeconds; // 총 시간 (초)
  final int elapsedSeconds; // 경과 시간 (초)
  final int readyCountdown; // 준비 카운트다운 (초)
  final int currentRound; // 현재 라운드 (세트)
  final int totalRounds; // 총 라운드 (세트)
  final TimerPhase phase; // 현재 페이즈 (운동/휴식)
  final int phaseRemainingSeconds; // 현재 페이즈 남은 초
  final int currentExerciseIndex; // EMOM/Tabata: 현재 운동 인덱스
  final int exerciseCount; // 총 운동 개수
  final WodType? wodType;

  const TimerState({
    this.status = TimerStatus.initial,
    this.totalSeconds = 0,
    this.elapsedSeconds = 0,
    this.readyCountdown = 10,
    this.currentRound = 1,
    this.totalRounds = 1,
    this.phase = TimerPhase.work,
    this.phaseRemainingSeconds = 0,
    this.currentExerciseIndex = 0,
    this.exerciseCount = 1,
    this.wodType,
  });

  /// 남은 시간 (초)
  int get remainingSeconds => totalSeconds - elapsedSeconds;

  /// 휴식 중인지 확인
  bool get isResting => phase == TimerPhase.rest;

  /// 운동 중인지 확인 (Tabata 등에서 사용)
  bool get isWorkPhase => phase == TimerPhase.work;

  /// 진행률 (0.0 ~ 1.0)
  double get progress =>
      totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;

  /// 현재 분:초 표시 (남은 시간)
  String get remainingTimeDisplay {
    final remaining = remainingSeconds.clamp(0, totalSeconds);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 경과 시간 표시
  String get elapsedTimeDisplay {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// EMOM: 현재 분 내 남은 초
  int get currentMinuteRemainingSeconds {
    if (wodType == WodType.emom) {
      return 60 - (elapsedSeconds % 60);
    }
    return remainingSeconds;
  }

  /// Tabata: 현재 구간 남은 초
  int get tabataPhaseRemainingSeconds {
    if (wodType != WodType.tabata) return phaseRemainingSeconds;

    const workDuration = 20;
    const restDuration = 10;
    const cycleDuration = workDuration + restDuration;

    final cycleElapsed = elapsedSeconds % cycleDuration;

    if (cycleElapsed < workDuration) {
      return workDuration - cycleElapsed;
    } else {
      return cycleDuration - cycleElapsed;
    }
  }

  TimerState copyWith({
    TimerStatus? status,
    int? totalSeconds,
    int? elapsedSeconds,
    int? readyCountdown,
    int? currentRound,
    int? totalRounds,
    TimerPhase? phase,
    int? phaseRemainingSeconds,
    int? currentExerciseIndex,
    int? exerciseCount,
    WodType? wodType,
  }) {
    return TimerState(
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      readyCountdown: readyCountdown ?? this.readyCountdown,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      phase: phase ?? this.phase,
      phaseRemainingSeconds: phaseRemainingSeconds ?? this.phaseRemainingSeconds,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      wodType: wodType ?? this.wodType,
    );
  }
}

/// 타이머 콜백 타입
typedef TimerCallback = void Function(TimerState state);

/// 운동 안내 콜백 타입 (운동 인덱스 전달)
typedef ExerciseAnnounceCallback = void Function(int exerciseIndex);

/// 타이머 Notifier
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  TimerCallback? _onRoundChange;
  TimerCallback? _onPhaseChange;
  TimerCallback? _onMinuteStart;
  TimerCallback? _onFinish;
  TimerCallback? _onWarning; // 5, 4, 3, 2, 1초 카운트다운
  TimerCallback? _onReadyBeep; // 준비 카운트다운 비프
  ExerciseAnnounceCallback? _onExerciseAnnounce; // 운동 종목 안내
  bool _hasAnnouncedFirstExercise = false; // 첫 운동 안내 여부

  TimerNotifier() : super(const TimerState());

  /// 콜백 설정
  void setCallbacks({
    TimerCallback? onRoundChange,
    TimerCallback? onPhaseChange,
    TimerCallback? onMinuteStart,
    TimerCallback? onFinish,
    TimerCallback? onWarning,
    TimerCallback? onReadyBeep,
    ExerciseAnnounceCallback? onExerciseAnnounce,
  }) {
    _onRoundChange = onRoundChange;
    _onPhaseChange = onPhaseChange;
    _onMinuteStart = onMinuteStart;
    _onFinish = onFinish;
    _onWarning = onWarning;
    _onReadyBeep = onReadyBeep;
    _onExerciseAnnounce = onExerciseAnnounce;
  }

  /// WOD에 맞는 타이머 초기화
  void initializeForWod(Wod wod) {
    _timer?.cancel();
    _hasAnnouncedFirstExercise = false;

    final totalSeconds = wod.duration * 60;
    final exerciseCount = wod.exercises.length > 0 ? wod.exercises.length : 1;
    int totalRounds = 1;

    switch (wod.type) {
      case WodType.amrap:
        totalRounds = 1;
        break;
      case WodType.emom:
        // 총 세트 수 = 총 분 / 운동 개수
        totalRounds = (wod.duration / exerciseCount).ceil();
        break;
      case WodType.forTime:
        totalRounds = wod.rounds ?? 1;
        break;
      case WodType.tabata:
        // 총 세트 수 = 8 (운동을 순서대로 8번 반복)
        totalRounds = 8;
        break;
    }

    state = TimerState(
      status: TimerStatus.initial,
      totalSeconds: totalSeconds,
      elapsedSeconds: 0,
      readyCountdown: 10,
      currentRound: 1,
      totalRounds: totalRounds,
      phase: TimerPhase.work,
      phaseRemainingSeconds: 0,
      currentExerciseIndex: 0,
      exerciseCount: exerciseCount,
      wodType: wod.type,
    );
  }

  /// 타이머 시작 (준비 카운트다운부터)
  void start() {
    if (state.status == TimerStatus.running ||
        state.status == TimerStatus.ready) {
      return;
    }

    // 준비 카운트다운 시작
    state = state.copyWith(
      status: TimerStatus.ready,
      readyCountdown: 10,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == TimerStatus.ready) {
        _handleReadyCountdown();
      } else if (state.status == TimerStatus.running) {
        _tick();
      }
    });
  }

  /// 준비 카운트다운 처리
  void _handleReadyCountdown() {
    final newCountdown = state.readyCountdown - 1;

    // EMOM/Tabata: 시작 10초 전에 첫 운동 종목 안내
    if (newCountdown == 9 && !_hasAnnouncedFirstExercise) {
      if (state.wodType == WodType.emom || state.wodType == WodType.tabata) {
        _onExerciseAnnounce?.call(0); // 첫 번째 운동
        _hasAnnouncedFirstExercise = true;
      }
    }

    // 5초 이하일 때 비프음
    if (newCountdown <= 5 && newCountdown > 0) {
      _onReadyBeep?.call(state.copyWith(readyCountdown: newCountdown));
    }

    if (newCountdown <= 0) {
      // 카운트다운 완료, 운동 시작
      state = state.copyWith(
        status: TimerStatus.running,
        readyCountdown: 0,
        phase: TimerPhase.work,
      );
      _onPhaseChange?.call(state);
    } else {
      state = state.copyWith(readyCountdown: newCountdown);
    }
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();
    if (state.status == TimerStatus.running) {
      state = state.copyWith(status: TimerStatus.paused);
    }
  }

  /// 타이머 재개
  void resume() {
    if (state.status != TimerStatus.paused) return;

    state = state.copyWith(status: TimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  /// 타이머 정지 및 초기화
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = TimerState(
      status: TimerStatus.initial,
      totalSeconds: state.totalSeconds,
      totalRounds: state.totalRounds,
      wodType: state.wodType,
    );
  }

  /// 타이머 완료
  void finish() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.finished);
    _onFinish?.call(state);
  }

  void _tick() {
    final newElapsed = state.elapsedSeconds + 1;

    // 타이머 종료 체크
    if (newElapsed >= state.totalSeconds) {
      finish();
      return;
    }

    // 전체 남은 시간 경고음 (5, 4, 3, 2, 1초)
    final remaining = state.totalSeconds - newElapsed;
    if (remaining <= 5 && remaining > 0) {
      _onWarning?.call(state.copyWith(elapsedSeconds: newElapsed));
    }

    // WOD 타입별 처리
    switch (state.wodType) {
      case WodType.emom:
        _handleEmomTick(newElapsed);
        break;
      case WodType.tabata:
        _handleTabataTick(newElapsed);
        break;
      default:
        state = state.copyWith(elapsedSeconds: newElapsed);
    }
  }

  void _handleEmomTick(int newElapsed) {
    final previousMinute = state.elapsedSeconds ~/ 60;
    final currentMinute = newElapsed ~/ 60;
    final secondsInMinute = newElapsed % 60;

    // 분 내 마지막 5초 경고
    final secondsRemaining = 60 - secondsInMinute;
    if (secondsRemaining <= 5 && secondsRemaining > 0) {
      _onWarning?.call(state.copyWith(elapsedSeconds: newElapsed));
    }

    // 운동을 순서대로 진행: 운동1→운동2→운동3 = 1세트, 다시 운동1→운동2→운동3 = 2세트...
    final exerciseCount = state.exerciseCount > 0 ? state.exerciseCount : 1;
    final exerciseIndex = currentMinute % exerciseCount;
    final roundNumber = currentMinute ~/ exerciseCount + 1;

    // 종료 10초 전에 다음 운동 안내 (마지막 분이 아닐 때)
    final totalMinutes = state.totalSeconds ~/ 60;
    if (secondsRemaining == 10 && currentMinute < totalMinutes - 1) {
      final nextExerciseIndex = (currentMinute + 1) % exerciseCount;
      _onExerciseAnnounce?.call(nextExerciseIndex);
    }

    state = state.copyWith(
      elapsedSeconds: newElapsed,
      currentRound: roundNumber,
      currentExerciseIndex: exerciseIndex,
      phaseRemainingSeconds: secondsRemaining,
    );

    // 새로운 분이 시작될 때
    if (currentMinute > previousMinute) {
      _onMinuteStart?.call(state);
      _onRoundChange?.call(state);
    }
  }

  void _handleTabataTick(int newElapsed) {
    const workDuration = 20;
    const restDuration = 10;
    const cycleDuration = workDuration + restDuration;

    final previousCycle = state.elapsedSeconds ~/ cycleDuration;
    final currentCycle = newElapsed ~/ cycleDuration;

    final cycleElapsed = newElapsed % cycleDuration;
    final isWork = cycleElapsed < workDuration;
    final newPhase = isWork ? TimerPhase.work : TimerPhase.rest;

    // 현재 페이즈 남은 시간
    int phaseRemaining;
    if (isWork) {
      phaseRemaining = workDuration - cycleElapsed;
    } else {
      phaseRemaining = cycleDuration - cycleElapsed;
    }

    // 페이즈 전환 5초 전 경고
    if (phaseRemaining <= 5 && phaseRemaining > 0) {
      _onWarning?.call(state.copyWith(
        elapsedSeconds: newElapsed,
        phaseRemainingSeconds: phaseRemaining,
      ));
    }

    // 운동/휴식 구간 전환
    if (newPhase != state.phase) {
      state = state.copyWith(
        elapsedSeconds: newElapsed,
        phase: newPhase,
        phaseRemainingSeconds: phaseRemaining,
      );
      _onPhaseChange?.call(state);

      // 휴식 시작 시 다음 운동 안내 (마지막 사이클이 아닐 때)
      if (newPhase == TimerPhase.rest) {
        final exerciseCount = state.exerciseCount > 0 ? state.exerciseCount : 1;
        final totalCycles = exerciseCount * 8; // Tabata는 8세트
        if (currentCycle < totalCycles - 1) {
          final nextExerciseIndex = (currentCycle + 1) % exerciseCount;
          _onExerciseAnnounce?.call(nextExerciseIndex);
        }
      }
    } else {
      state = state.copyWith(
        elapsedSeconds: newElapsed,
        phaseRemainingSeconds: phaseRemaining,
      );
    }

    // 새 사이클 시작 (라운드 변경)
    // 운동을 순서대로 진행: 운동1→운동2→운동3 = 1세트, 다시 운동1→운동2→운동3 = 2세트...
    if (currentCycle > previousCycle) {
      final exerciseCount = state.exerciseCount > 0 ? state.exerciseCount : 1;
      // 현재 운동 인덱스 = 사이클을 운동 개수로 나눈 나머지
      final exerciseIndex = currentCycle % exerciseCount;
      // 현재 세트(라운드) = 사이클을 운동 개수로 나눈 몫 + 1
      final roundNumber = currentCycle ~/ exerciseCount + 1;

      state = state.copyWith(
        currentRound: roundNumber,
        currentExerciseIndex: exerciseIndex,
      );
      _onRoundChange?.call(state);
    }
  }

  /// For Time: 수동으로 완료
  void completeForTime() {
    if (state.wodType == WodType.forTime) {
      finish();
    }
  }

  /// AMRAP: 라운드 증가
  void incrementRound() {
    if (state.wodType == WodType.amrap && state.status == TimerStatus.running) {
      state = state.copyWith(currentRound: state.currentRound + 1);
      _onRoundChange?.call(state);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// 타이머 Provider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

// 타이머 실행 중 여부
final isTimerRunningProvider = Provider<bool>((ref) {
  final timerState = ref.watch(timerProvider);
  return timerState.status == TimerStatus.running;
});
