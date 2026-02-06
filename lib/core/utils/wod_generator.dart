import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/models/exercise.dart';
import '../../data/models/wod.dart';

/// WOD 생성기
class WodGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  /// 코어 운동 ID 목록
  static const List<String> coreExerciseIds = [
    'sit_up',
    'plank_hold',
    'v_up',
    'hollow_hold',
    'flutter_kicks',
    'bicycle_crunch',
    'superman',
    'mountain_climber',
  ];

  /// 랜덤 WOD 생성
  Wod generateWod({
    required List<Exercise> availableExercises,
    Difficulty difficulty = Difficulty.intermediate,
    WodType? wodType,
    int? exerciseCount,
  }) {
    // WOD 타입이 지정되지 않으면 랜덤 선택
    final type = wodType ?? _getRandomWodType();

    // 난이도에 맞는 운동만 필터링
    final filteredExercises = availableExercises
        .where((e) => e.difficulty.index <= difficulty.index)
        .toList();

    if (filteredExercises.isEmpty) {
      throw Exception('사용 가능한 운동이 없습니다.');
    }

    switch (type) {
      case WodType.amrap:
        return _generateAmrap(filteredExercises, difficulty, exerciseCount);
      case WodType.emom:
        return _generateEmom(filteredExercises, difficulty, exerciseCount);
      case WodType.forTime:
        return _generateForTime(filteredExercises, difficulty, exerciseCount);
      case WodType.tabata:
        return _generateTabata(filteredExercises, difficulty, exerciseCount);
    }
  }

  WodType _getRandomWodType() {
    return WodType.values[_random.nextInt(WodType.values.length)];
  }

  /// AMRAP 생성
  Wod _generateAmrap(List<Exercise> exercises, Difficulty difficulty, int? customExerciseCount) {
    final duration = _getAmrapDuration(difficulty);
    final exerciseCount = customExerciseCount ?? (_random.nextInt(2) + 3); // 기본: 3-4개 운동
    final selectedExercises = _selectRandomExercises(exercises, exerciseCount);

    final wodExercises = selectedExercises.map((e) {
      return WodExercise(
        exercise: e,
        reps: _getReps(e, difficulty),
        weight: _getWeight(e, difficulty),
        distance: _getDistance(e),
        calories: _getCalories(e),
      );
    }).toList();

    return Wod(
      id: _uuid.v4(),
      type: WodType.amrap,
      difficulty: difficulty,
      exercises: wodExercises,
      duration: duration,
      createdAt: DateTime.now(),
    );
  }

  /// EMOM 생성
  Wod _generateEmom(List<Exercise> exercises, Difficulty difficulty, int? customExerciseCount) {
    final duration = _getEmomDuration(difficulty);
    final exerciseCount = customExerciseCount ?? (_random.nextInt(2) + 2); // 기본: 2-3개 운동
    final selectedExercises = _selectRandomExercises(exercises, exerciseCount);

    final wodExercises = selectedExercises.map((e) {
      return WodExercise(
        exercise: e,
        reps: _getEmomReps(e, difficulty),
        weight: _getWeight(e, difficulty),
        distance: _getEmomDistance(e),
        calories: _getEmomCalories(e),
      );
    }).toList();

    return Wod(
      id: _uuid.v4(),
      type: WodType.emom,
      difficulty: difficulty,
      exercises: wodExercises,
      duration: duration,
      rounds: duration, // EMOM은 분 수가 라운드 수
      createdAt: DateTime.now(),
    );
  }

  /// For Time 생성
  Wod _generateForTime(List<Exercise> exercises, Difficulty difficulty, int? customExerciseCount) {
    final timeCap = _getForTimeTimeCap(difficulty);
    final rounds = _getForTimeRounds(difficulty);
    final exerciseCount = customExerciseCount ?? (_random.nextInt(2) + 3); // 기본: 3-4개 운동
    final selectedExercises = _selectRandomExercises(exercises, exerciseCount);

    final wodExercises = selectedExercises.map((e) {
      return WodExercise(
        exercise: e,
        reps: _getReps(e, difficulty),
        weight: _getWeight(e, difficulty),
        distance: _getDistance(e),
        calories: _getCalories(e),
      );
    }).toList();

    return Wod(
      id: _uuid.v4(),
      type: WodType.forTime,
      difficulty: difficulty,
      exercises: wodExercises,
      duration: timeCap,
      rounds: rounds,
      createdAt: DateTime.now(),
    );
  }

  /// 코어 Tabata 생성
  Wod generateCoreTabata({
    required List<Exercise> availableExercises,
    Difficulty difficulty = Difficulty.intermediate,
    int? exerciseCount,
  }) {
    // 코어 운동만 필터링
    final coreExercises = availableExercises
        .where((e) => coreExerciseIds.contains(e.id))
        .where((e) => e.difficulty.index <= difficulty.index)
        .toList();

    if (coreExercises.isEmpty) {
      throw Exception('사용 가능한 코어 운동이 없습니다.');
    }

    final count = exerciseCount ?? (_random.nextInt(2) + 2); // 기본: 2-3개
    final selectedExercises = _selectRandomExercises(coreExercises, count);

    final wodExercises = selectedExercises.map((e) {
      return WodExercise(
        exercise: e,
        reps: 0, // Tabata는 시간 기반
        duration: 20, // 20초 운동
      );
    }).toList();

    // Tabata: 각 운동당 8라운드, 20초 운동 + 10초 휴식
    const rounds = 8;
    const durationPerExercise = (20 + 10) * rounds ~/ 60; // 분
    final totalDuration = durationPerExercise * selectedExercises.length;

    return Wod(
      id: _uuid.v4(),
      type: WodType.tabata,
      difficulty: difficulty,
      exercises: wodExercises,
      duration: totalDuration > 0 ? totalDuration : 4,
      rounds: rounds,
      createdAt: DateTime.now(),
    );
  }

  /// Tabata 생성
  Wod _generateTabata(List<Exercise> exercises, Difficulty difficulty, int? customExerciseCount) {
    // Tabata에 적합한 운동만 필터 (체조, 유산소)
    final tabataExercises = exercises
        .where((e) =>
            e.category == ExerciseCategory.gymnastics ||
            e.category == ExerciseCategory.cardio)
        .toList();

    final exerciseCount = customExerciseCount ?? (_random.nextInt(2) + 2); // 기본: 2-3개 운동
    final selectedExercises = tabataExercises.isEmpty
        ? _selectRandomExercises(exercises, exerciseCount)
        : _selectRandomExercises(tabataExercises, exerciseCount);

    final wodExercises = selectedExercises.map((e) {
      return WodExercise(
        exercise: e,
        reps: 0, // Tabata는 시간 기반이므로 reps 불필요
        duration: 20, // 20초 운동
      );
    }).toList();

    // Tabata: 각 운동당 8라운드, 20초 운동 + 10초 휴식
    const rounds = 8;
    const durationPerExercise = (20 + 10) * rounds ~/ 60; // 분
    final totalDuration = durationPerExercise * selectedExercises.length;

    return Wod(
      id: _uuid.v4(),
      type: WodType.tabata,
      difficulty: difficulty,
      exercises: wodExercises,
      duration: totalDuration > 0 ? totalDuration : 4,
      rounds: rounds,
      createdAt: DateTime.now(),
    );
  }

  List<Exercise> _selectRandomExercises(List<Exercise> exercises, int count) {
    if (exercises.length <= count) {
      return List.from(exercises);
    }

    final shuffled = List<Exercise>.from(exercises)..shuffle(_random);

    // 카테고리 다양성 확보
    final selected = <Exercise>[];
    final categoryCounts = <ExerciseCategory, int>{};

    for (final exercise in shuffled) {
      if (selected.length >= count) break;

      // 같은 카테고리가 2개 미만일 때만 추가
      final currentCount = categoryCounts[exercise.category] ?? 0;
      if (currentCount < 2) {
        selected.add(exercise);
        categoryCounts[exercise.category] = currentCount + 1;
      }
    }

    // 부족하면 나머지로 채움
    for (final exercise in shuffled) {
      if (selected.length >= count) break;
      if (!selected.contains(exercise)) {
        selected.add(exercise);
      }
    }

    return selected;
  }

  int _getAmrapDuration(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return [8, 10, 12][_random.nextInt(3)];
      case Difficulty.intermediate:
        return [12, 15, 18][_random.nextInt(3)];
      case Difficulty.advanced:
        return [15, 20, 25][_random.nextInt(3)];
    }
  }

  int _getEmomDuration(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return [8, 10, 12][_random.nextInt(3)];
      case Difficulty.intermediate:
        return [12, 15, 16][_random.nextInt(3)];
      case Difficulty.advanced:
        return [16, 20, 24][_random.nextInt(3)];
    }
  }

  int _getForTimeTimeCap(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return [10, 12, 15][_random.nextInt(3)];
      case Difficulty.intermediate:
        return [15, 18, 20][_random.nextInt(3)];
      case Difficulty.advanced:
        return [20, 25, 30][_random.nextInt(3)];
    }
  }

  int _getForTimeRounds(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return [2, 3][_random.nextInt(2)];
      case Difficulty.intermediate:
        return [3, 4, 5][_random.nextInt(3)];
      case Difficulty.advanced:
        return [4, 5, 6][_random.nextInt(3)];
    }
  }

  int _getReps(Exercise exercise, Difficulty difficulty) {
    // 카테고리별, 난이도별 기본 횟수
    final baseReps = <ExerciseCategory, Map<Difficulty, List<int>>>{
      ExerciseCategory.gymnastics: {
        Difficulty.beginner: [8, 10, 12],
        Difficulty.intermediate: [12, 15, 20],
        Difficulty.advanced: [15, 20, 25],
      },
      ExerciseCategory.weightlifting: {
        Difficulty.beginner: [6, 8, 10],
        Difficulty.intermediate: [8, 10, 12],
        Difficulty.advanced: [10, 12, 15],
      },
      ExerciseCategory.cardio: {
        Difficulty.beginner: [10, 15, 20],
        Difficulty.intermediate: [20, 30, 40],
        Difficulty.advanced: [30, 50, 75],
      },
      ExerciseCategory.monostructural: {
        Difficulty.beginner: [10, 15, 20],
        Difficulty.intermediate: [20, 30, 40],
        Difficulty.advanced: [30, 50, 75],
      },
    };

    final repsOptions = baseReps[exercise.category]?[difficulty] ?? [10, 15, 20];
    return repsOptions[_random.nextInt(repsOptions.length)];
  }

  int _getEmomReps(Exercise exercise, Difficulty difficulty) {
    // EMOM은 1분 내 완료 가능한 횟수
    final baseReps = <ExerciseCategory, Map<Difficulty, List<int>>>{
      ExerciseCategory.gymnastics: {
        Difficulty.beginner: [5, 8, 10],
        Difficulty.intermediate: [8, 10, 12],
        Difficulty.advanced: [10, 12, 15],
      },
      ExerciseCategory.weightlifting: {
        Difficulty.beginner: [3, 5, 6],
        Difficulty.intermediate: [5, 6, 8],
        Difficulty.advanced: [6, 8, 10],
      },
      ExerciseCategory.cardio: {
        Difficulty.beginner: [8, 10, 12],
        Difficulty.intermediate: [10, 15, 20],
        Difficulty.advanced: [15, 20, 25],
      },
      ExerciseCategory.monostructural: {
        Difficulty.beginner: [8, 10, 12],
        Difficulty.intermediate: [10, 15, 20],
        Difficulty.advanced: [15, 20, 25],
      },
    };

    final repsOptions = baseReps[exercise.category]?[difficulty] ?? [8, 10, 12];
    return repsOptions[_random.nextInt(repsOptions.length)];
  }

  double? _getWeight(Exercise exercise, Difficulty difficulty) {
    if (exercise.category != ExerciseCategory.weightlifting) {
      return null;
    }

    // 운동별 기본 무게 (남성 기준, lbs)
    final baseWeights = <String, Map<Difficulty, List<double>>>{
      'deadlift': {
        Difficulty.beginner: [95, 115, 135],
        Difficulty.intermediate: [135, 155, 185],
        Difficulty.advanced: [185, 225, 275],
      },
      'front_squat': {
        Difficulty.beginner: [65, 85, 95],
        Difficulty.intermediate: [95, 115, 135],
        Difficulty.advanced: [135, 155, 185],
      },
      'shoulder_press': {
        Difficulty.beginner: [45, 55, 65],
        Difficulty.intermediate: [65, 75, 85],
        Difficulty.advanced: [85, 95, 115],
      },
      'power_clean': {
        Difficulty.beginner: [65, 85, 95],
        Difficulty.intermediate: [95, 115, 135],
        Difficulty.advanced: [135, 155, 185],
      },
      'thruster': {
        Difficulty.beginner: [45, 65, 75],
        Difficulty.intermediate: [75, 95, 115],
        Difficulty.advanced: [115, 135, 155],
      },
      'snatch': {
        Difficulty.beginner: [45, 55, 75],
        Difficulty.intermediate: [75, 95, 115],
        Difficulty.advanced: [115, 135, 155],
      },
      'clean_and_jerk': {
        Difficulty.beginner: [65, 85, 95],
        Difficulty.intermediate: [95, 115, 135],
        Difficulty.advanced: [135, 155, 185],
      },
    };

    final weightOptions = baseWeights[exercise.id]?[difficulty];
    if (weightOptions == null) {
      // 기본 무게
      switch (difficulty) {
        case Difficulty.beginner:
          return [45, 55, 65][_random.nextInt(3)].toDouble();
        case Difficulty.intermediate:
          return [65, 85, 95][_random.nextInt(3)].toDouble();
        case Difficulty.advanced:
          return [95, 115, 135][_random.nextInt(3)].toDouble();
      }
    }

    return weightOptions[_random.nextInt(weightOptions.length)];
  }

  int? _getDistance(Exercise exercise) {
    if (exercise.id == 'run' || exercise.id == 'shuttle_run') {
      return [200, 400, 800][_random.nextInt(3)];
    }
    if (exercise.id == 'row') {
      return [250, 500, 1000][_random.nextInt(3)];
    }
    return null;
  }

  int? _getEmomDistance(Exercise exercise) {
    if (exercise.id == 'run') {
      return [100, 200][_random.nextInt(2)];
    }
    if (exercise.id == 'row') {
      return [150, 200, 250][_random.nextInt(3)];
    }
    return null;
  }

  int? _getCalories(Exercise exercise) {
    if (exercise.id == 'bike') {
      return [10, 15, 20][_random.nextInt(3)];
    }
    if (exercise.id == 'row') {
      return [10, 15, 20][_random.nextInt(3)];
    }
    if (exercise.id == 'ski_erg') {
      return [10, 15, 20][_random.nextInt(3)];
    }
    return null;
  }

  int? _getEmomCalories(Exercise exercise) {
    if (exercise.id == 'bike' ||
        exercise.id == 'row' ||
        exercise.id == 'ski_erg') {
      return [8, 10, 12][_random.nextInt(3)];
    }
    return null;
  }
}
