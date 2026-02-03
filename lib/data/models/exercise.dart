import 'package:hive/hive.dart';

part 'exercise.g.dart';

/// 운동 카테고리
@HiveType(typeId: 0)
enum ExerciseCategory {
  @HiveField(0)
  gymnastics, // 체조 (풀업, 버피 등)
  @HiveField(1)
  weightlifting, // 역도 (클린, 스내치 등)
  @HiveField(2)
  cardio, // 유산소 (달리기, 로잉 등)
  @HiveField(3)
  monostructural, // 단일구조 (러닝, 로잉 등)
}

/// 난이도
@HiveType(typeId: 1)
enum Difficulty {
  @HiveField(0)
  beginner, // 초급
  @HiveField(1)
  intermediate, // 중급
  @HiveField(2)
  advanced, // 고급
}

/// 운동 모델
@HiveType(typeId: 2)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final ExerciseCategory category;

  @HiveField(5)
  final Difficulty difficulty;

  @HiveField(6)
  final List<String> equipment;

  @HiveField(7)
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.difficulty,
    required this.equipment,
    this.videoUrl,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    ExerciseCategory? category,
    Difficulty? difficulty,
    List<String>? equipment,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.index,
      'difficulty': difficulty.index,
      'equipment': equipment,
      'videoUrl': videoUrl,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: ExerciseCategory.values[json['category'] as int],
      difficulty: Difficulty.values[json['difficulty'] as int],
      equipment: List<String>.from(json['equipment'] as List),
      videoUrl: json['videoUrl'] as String?,
    );
  }

  @override
  String toString() => 'Exercise(id: $id, name: $name, category: $category)';
}

/// WOD에서 사용되는 운동 정보 (횟수/무게 포함)
@HiveType(typeId: 3)
class WodExercise extends HiveObject {
  @HiveField(0)
  final Exercise exercise;

  @HiveField(1)
  final int reps; // 횟수

  @HiveField(2)
  final double? weight; // 무게 (lbs)

  @HiveField(3)
  final int? duration; // 시간 (초)

  @HiveField(4)
  final int? distance; // 거리 (m)

  @HiveField(5)
  final int? calories; // 칼로리

  WodExercise({
    required this.exercise,
    required this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.calories,
  });

  WodExercise copyWith({
    Exercise? exercise,
    int? reps,
    double? weight,
    int? duration,
    int? distance,
    int? calories,
  }) {
    return WodExercise(
      exercise: exercise ?? this.exercise,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
    );
  }

  /// 운동 설명 문자열 생성
  String get displayText {
    final buffer = StringBuffer();

    // Tabata: duration 기반 표시 (reps가 0일 때)
    if (duration != null && reps == 0) {
      buffer.write('$duration초 ${exercise.name}');
    } else if (distance != null) {
      // 거리 기반 운동
      buffer.write('$distance m ${exercise.name}');
    } else if (calories != null) {
      // 칼로리 기반 운동
      buffer.write('$calories cal ${exercise.name}');
    } else {
      // 기본: 횟수 기반
      buffer.write('$reps ${exercise.name}');
    }

    if (weight != null && weight! > 0) {
      buffer.write(' (${weight!.toInt()}lbs)');
    }

    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'calories': calories,
    };
  }

  factory WodExercise.fromJson(Map<String, dynamic> json) {
    return WodExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      reps: json['reps'] as int,
      weight: json['weight'] as double?,
      duration: json['duration'] as int?,
      distance: json['distance'] as int?,
      calories: json['calories'] as int?,
    );
  }
}
