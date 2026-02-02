// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wod.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WodTypeAdapter extends TypeAdapter<WodType> {
  @override
  final int typeId = 4;

  @override
  WodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WodType.amrap;
      case 1:
        return WodType.emom;
      case 2:
        return WodType.forTime;
      case 3:
        return WodType.tabata;
      default:
        return WodType.amrap;
    }
  }

  @override
  void write(BinaryWriter writer, WodType obj) {
    switch (obj) {
      case WodType.amrap:
        writer.writeByte(0);
        break;
      case WodType.emom:
        writer.writeByte(1);
        break;
      case WodType.forTime:
        writer.writeByte(2);
        break;
      case WodType.tabata:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WodAdapter extends TypeAdapter<Wod> {
  @override
  final int typeId = 5;

  @override
  Wod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wod(
      id: fields[0] as String,
      type: fields[1] as WodType,
      difficulty: fields[2] as Difficulty,
      exercises: (fields[3] as List).cast<WodExercise>(),
      duration: fields[4] as int,
      rounds: fields[5] as int?,
      createdAt: fields[6] as DateTime,
      name: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Wod obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.rounds)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
