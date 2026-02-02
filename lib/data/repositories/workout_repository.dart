import '../models/wod.dart';
import '../models/workout_record.dart';
import '../datasources/local_storage.dart';

/// 운동 기록 Repository
class WorkoutRepository {
  final LocalStorage _localStorage;

  WorkoutRepository(this._localStorage);

  // WOD 관련
  /// 모든 WOD 가져오기
  List<Wod> getAllWods() {
    return _localStorage.getAllWods();
  }

  /// 특정 WOD 가져오기
  Wod? getWod(String id) {
    return _localStorage.getWod(id);
  }

  /// WOD 저장
  Future<void> saveWod(Wod wod) async {
    await _localStorage.saveWod(wod);
  }

  /// WOD 삭제
  Future<void> deleteWod(String id) async {
    await _localStorage.deleteWod(id);
  }

  // WorkoutRecord 관련
  /// 모든 운동 기록 가져오기 (최신순)
  List<WorkoutRecord> getAllWorkoutRecords() {
    return _localStorage.getAllWorkoutRecords();
  }

  /// 특정 날짜의 운동 기록 가져오기
  List<WorkoutRecord> getWorkoutRecordsByDate(DateTime date) {
    return _localStorage.getWorkoutRecordsByDate(date);
  }

  /// 최근 N개의 운동 기록 가져오기
  List<WorkoutRecord> getRecentWorkoutRecords(int count) {
    final records = _localStorage.getAllWorkoutRecords();
    return records.take(count).toList();
  }

  /// 월별 운동 기록 가져오기
  List<WorkoutRecord> getWorkoutRecordsByMonth(int year, int month) {
    return _localStorage
        .getAllWorkoutRecords()
        .where((r) =>
            r.completedAt.year == year && r.completedAt.month == month)
        .toList();
  }

  /// 운동 기록 저장
  Future<void> saveWorkoutRecord(WorkoutRecord record) async {
    await _localStorage.saveWorkoutRecord(record);
  }

  /// 운동 기록 삭제
  Future<void> deleteWorkoutRecord(String id) async {
    await _localStorage.deleteWorkoutRecord(id);
  }

  /// WOD 타입별 기록 가져오기
  List<WorkoutRecord> getWorkoutRecordsByWodType(WodType type) {
    return _localStorage
        .getAllWorkoutRecords()
        .where((r) => r.wod.type == type)
        .toList();
  }

  /// 통계: 총 운동 횟수
  int getTotalWorkoutCount() {
    return _localStorage.getAllWorkoutRecords().length;
  }

  /// 통계: 이번 주 운동 횟수
  int getThisWeekWorkoutCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _localStorage
        .getAllWorkoutRecords()
        .where((r) => r.completedAt.isAfter(startDate))
        .length;
  }

  /// 통계: 이번 달 운동 횟수
  int getThisMonthWorkoutCount() {
    final now = DateTime.now();
    return _localStorage
        .getAllWorkoutRecords()
        .where((r) =>
            r.completedAt.year == now.year && r.completedAt.month == now.month)
        .length;
  }

  /// 통계: 연속 운동 일수
  int getWorkoutStreak() {
    final records = _localStorage.getAllWorkoutRecords();
    if (records.isEmpty) return 0;

    // 날짜별로 그룹화
    final workoutDays = <DateTime>{};
    for (final record in records) {
      workoutDays.add(DateTime(
        record.completedAt.year,
        record.completedAt.month,
        record.completedAt.day,
      ));
    }

    final sortedDays = workoutDays.toList()..sort((a, b) => b.compareTo(a));

    // 오늘부터 연속 일수 계산
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayDate;

    // 오늘 운동했는지 확인
    if (!sortedDays.contains(todayDate)) {
      // 어제 확인
      checkDate = todayDate.subtract(const Duration(days: 1));
      if (!sortedDays.contains(checkDate)) {
        return 0;
      }
    }

    while (sortedDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 운동한 날짜 목록 가져오기 (캘린더용)
  Set<DateTime> getWorkoutDates({int? year, int? month}) {
    var records = _localStorage.getAllWorkoutRecords();

    if (year != null && month != null) {
      records = records
          .where((r) =>
              r.completedAt.year == year && r.completedAt.month == month)
          .toList();
    }

    return records
        .map((r) => DateTime(
              r.completedAt.year,
              r.completedAt.month,
              r.completedAt.day,
            ))
        .toSet();
  }
}
