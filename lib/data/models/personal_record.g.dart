// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrUnitAdapter extends TypeAdapter<PrUnit> {
  @override
  final int typeId = 7;

  @override
  PrUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PrUnit.kg;
      case 1:
        return PrUnit.lb;
      case 2:
        return PrUnit.reps;
      case 3:
        return PrUnit.seconds;
      case 4:
        return PrUnit.meters;
      case 5:
        return PrUnit.calories;
      default:
        return PrUnit.kg;
    }
  }

  @override
  void write(BinaryWriter writer, PrUnit obj) {
    switch (obj) {
      case PrUnit.kg:
        writer.writeByte(0);
        break;
      case PrUnit.lb:
        writer.writeByte(1);
        break;
      case PrUnit.reps:
        writer.writeByte(2);
        break;
      case PrUnit.seconds:
        writer.writeByte(3);
        break;
      case PrUnit.meters:
        writer.writeByte(4);
        break;
      case PrUnit.calories:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonalRecordAdapter extends TypeAdapter<PersonalRecord> {
  @override
  final int typeId = 8;

  @override
  PersonalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecord(
      id: fields[0] as String,
      exerciseName: fields[1] as String,
      value: fields[2] as double,
      unit: fields[3] as PrUnit,
      recordedAt: fields[4] as DateTime,
      notes: fields[5] as String?,
      variation: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.recordedAt)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.variation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
