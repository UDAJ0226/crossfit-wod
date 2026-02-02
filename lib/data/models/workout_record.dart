import 'package:hive/hive.dart';
import 'wod.dart';

part 'workout_record.g.dart';

/// 운동 기록 모델
@HiveType(typeId: 6)
class WorkoutRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Wod wod;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final String result; // 라운드 수 또는 시간

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final int? roundsCompleted; // AMRAP용

  @HiveField(6)
  final int? repsCompleted; // 마지막 라운드 추가 반복 횟수

  @HiveField(7)
  final int? completionTimeSeconds; // For Time용 (초)

  @HiveField(8)
  final bool isRx; // Rx(처방대로) 수행 여부

  WorkoutRecord({
    required this.id,
    required this.wod,
    required this.completedAt,
    required this.result,
    this.notes,
    this.roundsCompleted,
    this.repsCompleted,
    this.completionTimeSeconds,
    this.isRx = true,
  });

  WorkoutRecord copyWith({
    String? id,
    Wod? wod,
    DateTime? completedAt,
    String? result,
    String? notes,
    int? roundsCompleted,
    int? repsCompleted,
    int? completionTimeSeconds,
    bool? isRx,
  }) {
    return WorkoutRecord(
      id: id ?? this.id,
      wod: wod ?? this.wod,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      roundsCompleted: roundsCompleted ?? this.roundsCompleted,
      repsCompleted: repsCompleted ?? this.repsCompleted,
      completionTimeSeconds: completionTimeSeconds ?? this.completionTimeSeconds,
      isRx: isRx ?? this.isRx,
    );
  }

  /// 결과 표시 문자열
  String get displayResult {
    switch (wod.type) {
      case WodType.amrap:
        if (roundsCompleted != null) {
          if (repsCompleted != null && repsCompleted! > 0) {
            return '$roundsCompleted라운드 + $repsCompleted회';
          }
          return '$roundsCompleted라운드';
        }
        return result;
      case WodType.forTime:
        if (completionTimeSeconds != null) {
          final minutes = completionTimeSeconds! ~/ 60;
          final seconds = completionTimeSeconds! % 60;
          return '$minutes:${seconds.toString().padLeft(2, '0')}';
        }
        return result;
      case WodType.emom:
      case WodType.tabata:
        return '완료';
    }
  }

  /// 날짜 표시 문자열
  String get displayDate {
    return '${completedAt.year}.${completedAt.month.toString().padLeft(2, '0')}.${completedAt.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wod': wod.toJson(),
      'completedAt': completedAt.toIso8601String(),
      'result': result,
      'notes': notes,
      'roundsCompleted': roundsCompleted,
      'repsCompleted': repsCompleted,
      'completionTimeSeconds': completionTimeSeconds,
      'isRx': isRx,
    };
  }

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      id: json['id'] as String,
      wod: Wod.fromJson(json['wod'] as Map<String, dynamic>),
      completedAt: DateTime.parse(json['completedAt'] as String),
      result: json['result'] as String,
      notes: json['notes'] as String?,
      roundsCompleted: json['roundsCompleted'] as int?,
      repsCompleted: json['repsCompleted'] as int?,
      completionTimeSeconds: json['completionTimeSeconds'] as int?,
      isRx: json['isRx'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'WorkoutRecord(id: $id, wod: ${wod.type}, result: $result)';
}
