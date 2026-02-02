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

// 선택된 날짜의 운동 기록 Provider
final selectedDateWorkoutsProvider = Provider<List<WorkoutRecord>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repository.getWorkoutRecordsByDate(selectedDate);
});

// 현재 월의 운동 날짜 Provider
final currentMonthWorkoutDatesProvider = Provider<Set<DateTime>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repository.getWorkoutDates(
    year: selectedDate.year,
    month: selectedDate.month,
  );
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

// 운동 통계 Provider
final workoutStatsProvider = Provider<WorkoutStats>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutStats(
    totalWorkouts: repository.getTotalWorkoutCount(),
    thisWeekWorkouts: repository.getThisWeekWorkoutCount(),
    thisMonthWorkouts: repository.getThisMonthWorkoutCount(),
    currentStreak: repository.getWorkoutStreak(),
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
