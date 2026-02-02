import 'package:hive/hive.dart';
import 'exercise.dart';

part 'wod.g.dart';

/// WOD 타입
@HiveType(typeId: 4)
enum WodType {
  @HiveField(0)
  amrap, // As Many Rounds As Possible
  @HiveField(1)
  emom, // Every Minute On the Minute
  @HiveField(2)
  forTime, // For Time
  @HiveField(3)
  tabata, // Tabata (20초 운동, 10초 휴식)
}

/// WOD 타입 확장
extension WodTypeExtension on WodType {
  String get displayName {
    switch (this) {
      case WodType.amrap:
        return 'AMRAP';
      case WodType.emom:
        return 'EMOM';
      case WodType.forTime:
        return 'For Time';
      case WodType.tabata:
        return 'Tabata';
    }
  }

  String get fullName {
    switch (this) {
      case WodType.amrap:
        return 'As Many Rounds As Possible';
      case WodType.emom:
        return 'Every Minute On the Minute';
      case WodType.forTime:
        return 'For Time';
      case WodType.tabata:
        return 'Tabata';
    }
  }

  String get description {
    switch (this) {
      case WodType.amrap:
        return '제한 시간 내 최대 라운드 수행';
      case WodType.emom:
        return '매분마다 지정된 운동 수행';
      case WodType.forTime:
        return '최대한 빠르게 운동 완료';
      case WodType.tabata:
        return '20초 운동, 10초 휴식 반복';
    }
  }
}

/// WOD (Workout of the Day) 모델
@HiveType(typeId: 5)
class Wod extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final WodType type;

  @HiveField(2)
  final Difficulty difficulty;

  @HiveField(3)
  final List<WodExercise> exercises;

  @HiveField(4)
  final int duration; // 분 단위

  @HiveField(5)
  final int? rounds; // For Time, EMOM용 라운드 수

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? name; // WOD 이름 (선택)

  Wod({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.exercises,
    required this.duration,
    this.rounds,
    required this.createdAt,
    this.name,
  });

  Wod copyWith({
    String? id,
    WodType? type,
    Difficulty? difficulty,
    List<WodExercise>? exercises,
    int? duration,
    int? rounds,
    DateTime? createdAt,
    String? name,
  }) {
    return Wod(
      id: id ?? this.id,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
    );
  }

  /// WOD 설명 생성
  String get summary {
    final buffer = StringBuffer();

    switch (type) {
      case WodType.amrap:
        buffer.write('$duration분 AMRAP');
        break;
      case WodType.emom:
        buffer.write('$duration분 EMOM');
        if (rounds != null) {
          buffer.write(' ($rounds라운드)');
        }
        break;
      case WodType.forTime:
        if (rounds != null && rounds! > 1) {
          buffer.write('$rounds라운드 For Time');
        } else {
          buffer.write('For Time');
        }
        buffer.write(' (Time Cap: $duration분)');
        break;
      case WodType.tabata:
        buffer.write('Tabata ($rounds라운드)');
        break;
    }

    return buffer.toString();
  }

  /// 총 운동 시간 (초)
  int get totalDurationSeconds => duration * 60;

  /// Tabata 설정
  static const int tabataWorkSeconds = 20;
  static const int tabataRestSeconds = 10;
  static const int tabataRoundsPerExercise = 8;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'difficulty': difficulty.index,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'duration': duration,
      'rounds': rounds,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
    };
  }

  factory Wod.fromJson(Map<String, dynamic> json) {
    return Wod(
      id: json['id'] as String,
      type: WodType.values[json['type'] as int],
      difficulty: Difficulty.values[json['difficulty'] as int],
      exercises: (json['exercises'] as List)
          .map((e) => WodExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as int,
      rounds: json['rounds'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String?,
    );
  }

  @override
  String toString() => 'Wod(id: $id, type: $type, difficulty: $difficulty)';
}
