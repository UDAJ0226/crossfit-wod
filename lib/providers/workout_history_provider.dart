import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/wod.dart';
import '../data/models/workout_record.dart';
import '../data/repositories/workout_repository.dart';
import 'wod_provider.dart';

// 운동 기록 목록 Provider
final workoutHistoryProvider = Provider<List<WorkoutRecord>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getAllWorkoutRecords();
});

// 최근 운동 기록 Provider (최근 10개)
final recentWorkoutHistoryProvider = Provider<List<WorkoutRecord>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getRecentWorkoutRecords(10);
});

// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// 선택된 날짜의 운동 기록 Provider (최적화: workoutHistoryProvider 재활용)
final selectedDateWorkoutsProvider = Provider<List<WorkoutRecord>>((ref) {
  final records = ref.watch(workoutHistoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return records
      .where((r) =>
          r.completedAt.year == selectedDate.year &&
          r.completedAt.month == selectedDate.month &&
          r.completedAt.day == selectedDate.day)
      .toList();
});

// 현재 월의 운동 날짜 Provider (최적화: workoutHistoryProvider 재활용)
final currentMonthWorkoutDatesProvider = Provider<Set<DateTime>>((ref) {
  final records = ref.watch(workoutHistoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return records
      .where((r) =>
          r.completedAt.year == selectedDate.year &&
          r.completedAt.month == selectedDate.month)
      .map((r) => DateTime(
            r.completedAt.year,
            r.completedAt.month,
            r.completedAt.day,
          ))
      .toSet();
});

// 운동 통계 클래스
class WorkoutStats {
  final int totalWorkouts;
  final int thisWeekWorkouts;
  final int thisMonthWorkouts;
  final int currentStreak;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.thisWeekWorkouts,
    required this.thisMonthWorkouts,
    required this.currentStreak,
  });
}

// 운동 통계 Provider (최적화: 한 번만 데이터 로드)
final workoutStatsProvider = Provider<WorkoutStats>((ref) {
  final records = ref.watch(workoutHistoryProvider);

  if (records.isEmpty) {
    return const WorkoutStats(
      totalWorkouts: 0,
      thisWeekWorkouts: 0,
      thisMonthWorkouts: 0,
      currentStreak: 0,
    );
  }

  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  // 이번 주 시작일
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStartDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  // 한 번의 순회로 모든 통계 계산
  int thisWeekCount = 0;
  int thisMonthCount = 0;
  final workoutDays = <DateTime>{};

  for (final record in records) {
    final recordDate = DateTime(
      record.completedAt.year,
      record.completedAt.month,
      record.completedAt.day,
    );

    workoutDays.add(recordDate);

    if (!record.completedAt.isBefore(weekStartDate)) {
      thisWeekCount++;
    }

    if (record.completedAt.year == now.year && record.completedAt.month == now.month) {
      thisMonthCount++;
    }
  }

  // 연속 일수 계산
  int streak = 0;
  DateTime checkDate = todayDate;

  if (!workoutDays.contains(todayDate)) {
    checkDate = todayDate.subtract(const Duration(days: 1));
    if (!workoutDays.contains(checkDate)) {
      streak = 0;
    } else {
      while (workoutDays.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
  } else {
    while (workoutDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
  }

  return WorkoutStats(
    totalWorkouts: records.length,
    thisWeekWorkouts: thisWeekCount,
    thisMonthWorkouts: thisMonthCount,
    currentStreak: streak,
  );
});

// 운동 기록 관리 Notifier
class WorkoutHistoryNotifier extends StateNotifier<AsyncValue<void>> {
  final WorkoutRepository _repository;
  final Uuid _uuid = const Uuid();

  WorkoutHistoryNotifier(this._repository) : super(const AsyncValue.data(null));

  /// 운동 기록 저장
  Future<WorkoutRecord> saveWorkoutRecord({
    required Wod wod,
    required String result,
    String? notes,
    int? roundsCompleted,
    int? repsCompleted,
    int? completionTimeSeconds,
    bool isRx = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final record = WorkoutRecord(
        id: _uuid.v4(),
        wod: wod,
        completedAt: DateTime.now(),
        result: result,
        notes: notes,
        roundsCompleted: roundsCompleted,
        repsCompleted: repsCompleted,
        completionTimeSeconds: completionTimeSeconds,
        isRx: isRx,
      );

      await _repository.saveWorkoutRecord(record);
      state = const AsyncValue.data(null);
      return record;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 운동 기록 삭제
  Future<void> deleteWorkoutRecord(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteWorkoutRecord(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// AMRAP 결과 기록
  Future<WorkoutRecord> saveAmrapResult({
    required Wod wod,
    required int rounds,
    int extraReps = 0,
    String? notes,
    bool isRx = true,
  }) async {
    final result =
        extraReps > 0 ? '$rounds라운드 + $extraReps회' : '$rounds라운드';

    return saveWorkoutRecord(
      wod: wod,
      result: result,
      roundsCompleted: rounds,
      repsCompleted: extraReps,
      notes: notes,
      isRx: isRx,
    );
  }

  /// For Time 결과 기록
  Future<WorkoutRecord> saveForTimeResult({
    required Wod wod,
    required int completionTimeSeconds,
    String? notes,
    bool isRx = true,
  }) async {
    final minutes = completionTimeSeconds ~/ 60;
    final seconds = completionTimeSeconds % 60;
    final result = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return saveWorkoutRecord(
      wod: wod,
      result: result,
      completionTimeSeconds: completionTimeSeconds,
      notes: notes,
      isRx: isRx,
    );
  }

  /// EMOM/Tabata 완료 기록
  Future<WorkoutRecord> saveCompletedResult({
    required Wod wod,
    String? notes,
    bool isRx = true,
  }) async {
    return saveWorkoutRecord(
      wod: wod,
      result: '완료',
      notes: notes,
      isRx: isRx,
    );
  }
}

// 운동 기록 관리 Provider
final workoutHistoryNotifierProvider =
    StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutHistoryNotifier(repository);
});

// WOD 타입별 기록 Provider
final wodTypeRecordsProvider =
    Provider.family<List<WorkoutRecord>, WodType>((ref, type) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutRecordsByWodType(type);
});
