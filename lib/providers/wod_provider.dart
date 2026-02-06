import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/wod_generator.dart';
import '../data/models/exercise.dart';
import '../data/models/wod.dart';
import '../data/datasources/local_storage.dart';
import '../data/repositories/exercise_repository.dart';
import '../data/repositories/workout_repository.dart';

// LocalStorage Provider
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage.instance;
});

// Repository Providers
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return ExerciseRepository(localStorage);
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return WorkoutRepository(localStorage);
});

// WOD Generator Provider
final wodGeneratorProvider = Provider<WodGenerator>((ref) {
  return WodGenerator();
});

// 선택된 난이도 Provider
final selectedDifficultyProvider =
    StateProvider<Difficulty>((ref) => Difficulty.intermediate);

// 선택된 WOD 타입 Provider (null이면 랜덤)
final selectedWodTypeProvider = StateProvider<WodType?>((ref) => null);

// 홈트레이닝 모드 (장비 없음) Provider
final homeTrainingModeProvider = StateProvider<bool>((ref) => false);

// 생성 모드 (자동/수동)
enum GenerationMode { auto, manual }
final generationModeProvider = StateProvider<GenerationMode>((ref) => GenerationMode.auto);

// 수동 모드 운동 갯수 (1-8)
final manualExerciseCountProvider = StateProvider<int>((ref) => 4);

// 모든 운동 목록 Provider
final exercisesProvider = Provider<List<Exercise>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAllExercises();
});

// 현재 WOD State
class CurrentWodState {
  final Wod? wod;
  final bool isLoading;
  final String? error;

  const CurrentWodState({
    this.wod,
    this.isLoading = false,
    this.error,
  });

  CurrentWodState copyWith({
    Wod? wod,
    bool? isLoading,
    String? error,
  }) {
    return CurrentWodState(
      wod: wod ?? this.wod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 현재 WOD Notifier
class CurrentWodNotifier extends StateNotifier<CurrentWodState> {
  final WodGenerator _generator;
  final ExerciseRepository _exerciseRepository;
  final WorkoutRepository _workoutRepository;
  final Ref _ref;

  CurrentWodNotifier(
    this._generator,
    this._exerciseRepository,
    this._workoutRepository,
    this._ref,
  ) : super(const CurrentWodState());

  /// 새 WOD 생성
  Future<void> generateWod() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final difficulty = _ref.read(selectedDifficultyProvider);
      final wodType = _ref.read(selectedWodTypeProvider);
      final homeTrainingMode = _ref.read(homeTrainingModeProvider);
      final generationMode = _ref.read(generationModeProvider);
      final manualExerciseCount = _ref.read(manualExerciseCountProvider);
      final exercises = _exerciseRepository.getAllExercises();

      if (exercises.isEmpty) {
        await _exerciseRepository.loadInitialExercises();
      }

      // 홈트레이닝 모드: 장비 없는 운동만 / 일반 모드: 홈트 전용 20개 제외
      final availableExercises = homeTrainingMode
          ? _exerciseRepository.getHomeTrainingExercises()
          : _exerciseRepository.getNormalModeExercises();

      // 자동: 4개 고정, 수동: 선택한 갯수
      final exerciseCount = generationMode == GenerationMode.auto
          ? 4
          : manualExerciseCount;

      final wod = _generator.generateWod(
        availableExercises: availableExercises,
        difficulty: difficulty,
        wodType: wodType,
        exerciseCount: exerciseCount,
      );

      // 생성된 WOD 저장
      await _workoutRepository.saveWod(wod);

      state = CurrentWodState(wod: wod);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'WOD 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 코어 Tabata 생성
  Future<void> generateCoreTabata() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final difficulty = _ref.read(selectedDifficultyProvider);
      final exercises = _exerciseRepository.getAllExercises();

      if (exercises.isEmpty) {
        await _exerciseRepository.loadInitialExercises();
      }

      // 코어 Tabata는 모든 운동에서 코어만 선택 (홈트 모드 무관)
      final availableExercises = _exerciseRepository.getAllExercises();

      final wod = _generator.generateCoreTabata(
        availableExercises: availableExercises,
        difficulty: difficulty,
        exerciseCount: 4, // 항상 4개 고정
      );

      // 생성된 WOD 저장
      await _workoutRepository.saveWod(wod);

      state = CurrentWodState(wod: wod);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '코어 Tabata 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// WOD 설정
  void setWod(Wod wod) {
    state = CurrentWodState(wod: wod);
  }

  /// WOD 초기화
  void clearWod() {
    state = const CurrentWodState();
  }
}

// 현재 WOD Provider
final currentWodProvider =
    StateNotifierProvider<CurrentWodNotifier, CurrentWodState>((ref) {
  final generator = ref.watch(wodGeneratorProvider);
  final exerciseRepository = ref.watch(exerciseRepositoryProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  return CurrentWodNotifier(
    generator,
    exerciseRepository,
    workoutRepository,
    ref,
  );
});

// 저장된 WOD 목록 Provider
final savedWodsProvider = Provider<List<Wod>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getAllWods();
});

// WOD 타입별 색상 가져오기
extension WodTypeColor on WodType {
  int get colorValue {
    switch (this) {
      case WodType.amrap:
        return 0xFF9C27B0; // Purple
      case WodType.emom:
        return 0xFF2196F3; // Blue
      case WodType.forTime:
        return 0xFFFF5722; // Deep Orange
      case WodType.tabata:
        return 0xFF00BCD4; // Cyan
    }
  }
}

// 난이도별 색상 가져오기
extension DifficultyColor on Difficulty {
  int get colorValue {
    switch (this) {
      case Difficulty.beginner:
        return 0xFF4CAF50; // Green
      case Difficulty.intermediate:
        return 0xFFFF9800; // Orange
      case Difficulty.advanced:
        return 0xFFF44336; // Red
    }
  }

  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
    }
  }
}
