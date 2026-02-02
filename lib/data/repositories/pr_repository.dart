import '../models/personal_record.dart';
import '../datasources/local_storage.dart';

/// 개인 기록 (PR) Repository
class PrRepository {
  final LocalStorage _localStorage;

  PrRepository(this._localStorage);

  /// 모든 개인 기록 가져오기
  List<PersonalRecord> getAllPersonalRecords() {
    return _localStorage.getAllPersonalRecords();
  }

  /// 특정 운동의 개인 기록 가져오기
  List<PersonalRecord> getPersonalRecordsByExercise(String exerciseName) {
    return _localStorage.getPersonalRecordsByExercise(exerciseName);
  }

  /// 특정 운동의 최고 기록 가져오기
  PersonalRecord? getBestRecord(String exerciseName, {String? variation}) {
    return _localStorage.getBestRecord(exerciseName, variation: variation);
  }

  /// 개인 기록 저장
  Future<void> savePersonalRecord(PersonalRecord record) async {
    await _localStorage.savePersonalRecord(record);
  }

  /// 개인 기록 삭제
  Future<void> deletePersonalRecord(String id) async {
    await _localStorage.deletePersonalRecord(id);
  }

  /// 운동별 최고 기록 목록 가져오기
  Map<String, PersonalRecord> getAllBestRecords() {
    final allRecords = _localStorage.getAllPersonalRecords();
    final bestRecords = <String, PersonalRecord>{};

    for (final record in allRecords) {
      final key = '${record.exerciseName}_${record.variation ?? ''}';
      if (!bestRecords.containsKey(key) ||
          _isBetterRecord(record, bestRecords[key]!)) {
        bestRecords[key] = record;
      }
    }

    return bestRecords;
  }

  /// 기록 비교 (시간/칼로리는 낮을수록, 나머지는 높을수록 좋음)
  bool _isBetterRecord(PersonalRecord newRecord, PersonalRecord oldRecord) {
    if (newRecord.unit == PrUnit.seconds || newRecord.unit == PrUnit.calories) {
      return newRecord.value < oldRecord.value;
    }
    return newRecord.value > oldRecord.value;
  }

  /// 최근 기록 가져오기
  List<PersonalRecord> getRecentRecords(int count) {
    final records = _localStorage.getAllPersonalRecords();
    return records.take(count).toList();
  }

  /// 새 기록인지 확인
  bool isNewRecord(String exerciseName, double value, PrUnit unit, {String? variation}) {
    final bestRecord = getBestRecord(exerciseName, variation: variation);
    if (bestRecord == null) return true;

    // 시간/칼로리는 낮을수록 좋음
    if (unit == PrUnit.seconds || unit == PrUnit.calories) {
      return value < bestRecord.value;
    }
    return value > bestRecord.value;
  }

  /// PR 카테고리 (주요 역도 운동)
  static List<String> get prExercises => [
        '백스쿼트',
        '프론트 스쿼트',
        '오버헤드 스쿼트',
        '데드리프트',
        '클린',
        '파워 클린',
        '클린 앤 저크',
        '스내치',
        '파워 스내치',
        '저크',
        '푸시 프레스',
        '숄더 프레스',
        '벤치 프레스',
        '쓰러스터',
        '풀업',
        '토즈 투 바',
        '핸드스탠드 푸시업',
        '핸드스탠드 워크',
        '더블언더',
        '로잉 500m',
        '로잉 2000m',
        '달리기 400m',
        '달리기 1마일',
      ];

  /// PR 변형 (RM)
  static List<String> get prVariations => [
        '1RM',
        '2RM',
        '3RM',
        '5RM',
        'Max Unbroken',
        'Max Reps',
        'Best Time',
      ];

  /// 특정 기간의 기록 가져오기
  List<PersonalRecord> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _localStorage
        .getAllPersonalRecords()
        .where((r) =>
            r.recordedAt.isAfter(startDate) && r.recordedAt.isBefore(endDate))
        .toList();
  }

  /// 월별 PR 개수
  int getMonthlyPrCount(int year, int month) {
    return _localStorage
        .getAllPersonalRecords()
        .where(
            (r) => r.recordedAt.year == year && r.recordedAt.month == month)
        .length;
  }
}
