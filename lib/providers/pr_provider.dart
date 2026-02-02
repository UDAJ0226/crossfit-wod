import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/personal_record.dart';
import '../data/repositories/pr_repository.dart';
import 'wod_provider.dart';

// PR Repository Provider
final prRepositoryProvider = Provider<PrRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return PrRepository(localStorage);
});

// 모든 개인 기록 Provider
final allPersonalRecordsProvider = Provider<List<PersonalRecord>>((ref) {
  final repository = ref.watch(prRepositoryProvider);
  return repository.getAllPersonalRecords();
});

// 운동별 최고 기록 Map Provider
final bestRecordsProvider = Provider<Map<String, PersonalRecord>>((ref) {
  final repository = ref.watch(prRepositoryProvider);
  return repository.getAllBestRecords();
});

// 최근 PR 목록 Provider (최근 10개)
final recentPrProvider = Provider<List<PersonalRecord>>((ref) {
  final repository = ref.watch(prRepositoryProvider);
  return repository.getRecentRecords(10);
});

// PR 운동 목록 Provider
final prExercisesProvider = Provider<List<String>>((ref) {
  return PrRepository.prExercises;
});

// PR 변형 목록 Provider
final prVariationsProvider = Provider<List<String>>((ref) {
  return PrRepository.prVariations;
});

// 선택된 운동의 PR 기록 Provider
final selectedExercisePrProvider =
    Provider.family<List<PersonalRecord>, String>((ref, exerciseName) {
  final repository = ref.watch(prRepositoryProvider);
  return repository.getPersonalRecordsByExercise(exerciseName);
});

// PR 관리 Notifier
class PrNotifier extends StateNotifier<AsyncValue<void>> {
  final PrRepository _repository;
  final Uuid _uuid = const Uuid();

  PrNotifier(this._repository) : super(const AsyncValue.data(null));

  /// PR 저장
  Future<PersonalRecord> savePersonalRecord({
    required String exerciseName,
    required double value,
    required PrUnit unit,
    String? notes,
    String? variation,
  }) async {
    state = const AsyncValue.loading();

    try {
      final record = PersonalRecord(
        id: _uuid.v4(),
        exerciseName: exerciseName,
        value: value,
        unit: unit,
        recordedAt: DateTime.now(),
        notes: notes,
        variation: variation,
      );

      await _repository.savePersonalRecord(record);
      state = const AsyncValue.data(null);
      return record;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// PR 삭제
  Future<void> deletePersonalRecord(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deletePersonalRecord(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 새 기록인지 확인
  bool isNewRecord(String exerciseName, double value, PrUnit unit, {String? variation}) {
    return _repository.isNewRecord(
      exerciseName,
      value,
      unit,
      variation: variation,
    );
  }

  /// 역도 1RM 저장 (lbs)
  Future<PersonalRecord> saveWeightPr({
    required String exerciseName,
    required double weightLbs,
    String? notes,
    String variation = '1RM',
  }) async {
    return savePersonalRecord(
      exerciseName: exerciseName,
      value: weightLbs,
      unit: PrUnit.lb,
      notes: notes,
      variation: variation,
    );
  }

  /// 횟수 기록 저장
  Future<PersonalRecord> saveRepsPr({
    required String exerciseName,
    required int reps,
    String? notes,
    String variation = 'Max Unbroken',
  }) async {
    return savePersonalRecord(
      exerciseName: exerciseName,
      value: reps.toDouble(),
      unit: PrUnit.reps,
      notes: notes,
      variation: variation,
    );
  }

  /// 시간 기록 저장 (초)
  Future<PersonalRecord> saveTimePr({
    required String exerciseName,
    required int seconds,
    String? notes,
    String variation = 'Best Time',
  }) async {
    return savePersonalRecord(
      exerciseName: exerciseName,
      value: seconds.toDouble(),
      unit: PrUnit.seconds,
      notes: notes,
      variation: variation,
    );
  }
}

// PR 관리 Provider
final prNotifierProvider =
    StateNotifierProvider<PrNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(prRepositoryProvider);
  return PrNotifier(repository);
});

// 선택된 PR 운동
final selectedPrExerciseProvider = StateProvider<String?>((ref) => null);

// 선택된 PR 변형
final selectedPrVariationProvider = StateProvider<String?>((ref) => null);

// 월별 PR 개수 Provider
final monthlyPrCountProvider =
    Provider.family<int, ({int year, int month})>((ref, params) {
  final repository = ref.watch(prRepositoryProvider);
  return repository.getMonthlyPrCount(params.year, params.month);
});
