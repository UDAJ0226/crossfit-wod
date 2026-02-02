import 'package:hive/hive.dart';

part 'personal_record.g.dart';

/// PR 단위 타입
@HiveType(typeId: 7)
enum PrUnit {
  @HiveField(0)
  kg, // 무게
  @HiveField(1)
  lb, // 파운드
  @HiveField(2)
  reps, // 횟수
  @HiveField(3)
  seconds, // 시간 (초)
  @HiveField(4)
  meters, // 거리
  @HiveField(5)
  calories, // 칼로리
}

extension PrUnitExtension on PrUnit {
  String get displayName {
    switch (this) {
      case PrUnit.kg:
        return 'kg';
      case PrUnit.lb:
        return 'lb';
      case PrUnit.reps:
        return '회';
      case PrUnit.seconds:
        return '초';
      case PrUnit.meters:
        return 'm';
      case PrUnit.calories:
        return 'cal';
    }
  }
}

/// 개인 기록 (PR) 모델
@HiveType(typeId: 8)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseName; // 운동 이름

  @HiveField(2)
  final double value; // 기록 값

  @HiveField(3)
  final PrUnit unit; // 단위

  @HiveField(4)
  final DateTime recordedAt; // 기록 날짜

  @HiveField(5)
  final String? notes; // 메모

  @HiveField(6)
  final String? variation; // 변형 (예: "1RM", "3RM", "Max Unbroken")

  PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
    this.variation,
  });

  PersonalRecord copyWith({
    String? id,
    String? exerciseName,
    double? value,
    PrUnit? unit,
    DateTime? recordedAt,
    String? notes,
    String? variation,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      variation: variation ?? this.variation,
    );
  }

  /// 기록 표시 문자열
  String get displayValue {
    if (unit == PrUnit.seconds) {
      final minutes = value.toInt() ~/ 60;
      final seconds = value.toInt() % 60;
      if (minutes > 0) {
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      }
      return '$seconds초';
    }

    // 소수점이 없으면 정수로 표시
    if (value == value.toInt()) {
      return '${value.toInt()}${unit.displayName}';
    }
    return '${value.toStringAsFixed(1)}${unit.displayName}';
  }

  /// 날짜 표시 문자열
  String get displayDate {
    return '${recordedAt.year}.${recordedAt.month.toString().padLeft(2, '0')}.${recordedAt.day.toString().padLeft(2, '0')}';
  }

  /// 전체 표시 문자열 (운동 이름 + 변형 + 기록)
  String get fullDisplay {
    final buffer = StringBuffer(exerciseName);
    if (variation != null && variation!.isNotEmpty) {
      buffer.write(' ($variation)');
    }
    buffer.write(': $displayValue');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'value': value,
      'unit': unit.index,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'variation': variation,
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      exerciseName: json['exerciseName'] as String,
      value: (json['value'] as num).toDouble(),
      unit: PrUnit.values[json['unit'] as int],
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      variation: json['variation'] as String?,
    );
  }

  @override
  String toString() =>
      'PersonalRecord(id: $id, exercise: $exerciseName, value: $displayValue)';
}
