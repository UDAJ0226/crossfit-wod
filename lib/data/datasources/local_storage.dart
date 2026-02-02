import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/wod.dart';
import '../models/workout_record.dart';
import '../models/personal_record.dart';

/// 로컬 스토리지 관리 클래스
class LocalStorage {
  static const String _exerciseBox = 'exercises';
  static const String _wodBox = 'wods';
  static const String _workoutRecordBox = 'workout_records';
  static const String _personalRecordBox = 'personal_records';
  static const String _settingsBox = 'settings';

  static LocalStorage? _instance;
  static LocalStorage get instance => _instance ??= LocalStorage._();

  LocalStorage._();

  late Box<Exercise> _exerciseBoxInstance;
  late Box<Wod> _wodBoxInstance;
  late Box<WorkoutRecord> _workoutRecordBoxInstance;
  late Box<PersonalRecord> _personalRecordBoxInstance;
  late Box<dynamic> _settingsBoxInstance;

  bool _isInitialized = false;

  /// 초기화
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // 어댑터 등록
    _registerAdapters();

    // 박스 병렬로 열기 (성능 최적화)
    final results = await Future.wait([
      Hive.openBox<Exercise>(_exerciseBox),
      Hive.openBox<Wod>(_wodBox),
      Hive.openBox<WorkoutRecord>(_workoutRecordBox),
      Hive.openBox<PersonalRecord>(_personalRecordBox),
      Hive.openBox(_settingsBox),
    ]);

    _exerciseBoxInstance = results[0] as Box<Exercise>;
    _wodBoxInstance = results[1] as Box<Wod>;
    _workoutRecordBoxInstance = results[2] as Box<WorkoutRecord>;
    _personalRecordBoxInstance = results[3] as Box<PersonalRecord>;
    _settingsBoxInstance = results[4];

    _isInitialized = true;
  }

  void _registerAdapters() {
    // 이미 등록된 어댑터는 건너뜀
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DifficultyAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WodExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WodTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(WodAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(WorkoutRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PrUnitAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(PersonalRecordAdapter());
    }
  }

  // Exercise 관련
  Box<Exercise> get exerciseBox => _exerciseBoxInstance;

  Future<void> saveExercise(Exercise exercise) async {
    await _exerciseBoxInstance.put(exercise.id, exercise);
  }

  Future<void> saveAllExercises(List<Exercise> exercises) async {
    final map = {for (var e in exercises) e.id: e};
    await _exerciseBoxInstance.putAll(map);
  }

  List<Exercise> getAllExercises() {
    return _exerciseBoxInstance.values.toList();
  }

  Exercise? getExercise(String id) {
    return _exerciseBoxInstance.get(id);
  }

  // WOD 관련
  Box<Wod> get wodBox => _wodBoxInstance;

  Future<void> saveWod(Wod wod) async {
    await _wodBoxInstance.put(wod.id, wod);
  }

  List<Wod> getAllWods() {
    return _wodBoxInstance.values.toList();
  }

  Wod? getWod(String id) {
    return _wodBoxInstance.get(id);
  }

  Future<void> deleteWod(String id) async {
    await _wodBoxInstance.delete(id);
  }

  // WorkoutRecord 관련
  Box<WorkoutRecord> get workoutRecordBox => _workoutRecordBoxInstance;

  Future<void> saveWorkoutRecord(WorkoutRecord record) async {
    await _workoutRecordBoxInstance.put(record.id, record);
  }

  List<WorkoutRecord> getAllWorkoutRecords() {
    final records = _workoutRecordBoxInstance.values.toList();
    // 최신순 정렬
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  List<WorkoutRecord> getWorkoutRecordsByDate(DateTime date) {
    return _workoutRecordBoxInstance.values
        .where((r) =>
            r.completedAt.year == date.year &&
            r.completedAt.month == date.month &&
            r.completedAt.day == date.day)
        .toList();
  }

  Future<void> deleteWorkoutRecord(String id) async {
    await _workoutRecordBoxInstance.delete(id);
  }

  // PersonalRecord 관련
  Box<PersonalRecord> get personalRecordBox => _personalRecordBoxInstance;

  Future<void> savePersonalRecord(PersonalRecord record) async {
    await _personalRecordBoxInstance.put(record.id, record);
  }

  List<PersonalRecord> getAllPersonalRecords() {
    final records = _personalRecordBoxInstance.values.toList();
    // 최신순 정렬
    records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records;
  }

  List<PersonalRecord> getPersonalRecordsByExercise(String exerciseName) {
    return _personalRecordBoxInstance.values
        .where((r) => r.exerciseName == exerciseName)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  /// 특정 운동의 최고 기록 가져오기
  PersonalRecord? getBestRecord(String exerciseName, {String? variation}) {
    final records = _personalRecordBoxInstance.values
        .where((r) =>
            r.exerciseName == exerciseName &&
            (variation == null || r.variation == variation))
        .toList();

    if (records.isEmpty) return null;

    // 가장 높은 값 반환
    records.sort((a, b) => b.value.compareTo(a.value));
    return records.first;
  }

  Future<void> deletePersonalRecord(String id) async {
    await _personalRecordBoxInstance.delete(id);
  }

  // Settings 관련
  Box<dynamic> get settingsBox => _settingsBoxInstance;

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBoxInstance.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue) as T?;
  }

  /// 데이터 버전 확인 (운동 데이터 갱신 필요 여부)
  int get dataVersion => getSetting<int>('dataVersion', defaultValue: 0) ?? 0;

  Future<void> setDataVersion(int version) async {
    await saveSetting('dataVersion', version);
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    await _exerciseBoxInstance.clear();
    await _wodBoxInstance.clear();
    await _workoutRecordBoxInstance.clear();
    await _personalRecordBoxInstance.clear();
    await _settingsBoxInstance.clear();
  }

  /// 운동 데이터만 초기화
  Future<void> clearExercises() async {
    await _exerciseBoxInstance.clear();
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await Hive.close();
    _isInitialized = false;
  }
}
