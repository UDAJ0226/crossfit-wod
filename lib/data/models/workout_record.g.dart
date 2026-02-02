// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutRecordAdapter extends TypeAdapter<WorkoutRecord> {
  @override
  final int typeId = 6;

  @override
  WorkoutRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutRecord(
      id: fields[0] as String,
      wod: fields[1] as Wod,
      completedAt: fields[2] as DateTime,
      result: fields[3] as String,
      notes: fields[4] as String?,
      roundsCompleted: fields[5] as int?,
      repsCompleted: fields[6] as int?,
      completionTimeSeconds: fields[7] as int?,
      isRx: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wod)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.result)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.roundsCompleted)
      ..writeByte(6)
      ..write(obj.repsCompleted)
      ..writeByte(7)
      ..write(obj.completionTimeSeconds)
      ..writeByte(8)
      ..write(obj.isRx);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
