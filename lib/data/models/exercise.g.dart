// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseCategoryAdapter extends TypeAdapter<ExerciseCategory> {
  @override
  final int typeId = 0;

  @override
  ExerciseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseCategory.gymnastics;
      case 1:
        return ExerciseCategory.weightlifting;
      case 2:
        return ExerciseCategory.cardio;
      case 3:
        return ExerciseCategory.monostructural;
      default:
        return ExerciseCategory.gymnastics;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseCategory obj) {
    switch (obj) {
      case ExerciseCategory.gymnastics:
        writer.writeByte(0);
        break;
      case ExerciseCategory.weightlifting:
        writer.writeByte(1);
        break;
      case ExerciseCategory.cardio:
        writer.writeByte(2);
        break;
      case ExerciseCategory.monostructural:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 1;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.beginner;
      case 1:
        return Difficulty.intermediate;
      case 2:
        return Difficulty.advanced;
      default:
        return Difficulty.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.beginner:
        writer.writeByte(0);
        break;
      case Difficulty.intermediate:
        writer.writeByte(1);
        break;
      case Difficulty.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 2;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String?,
      category: fields[4] as ExerciseCategory,
      difficulty: fields[5] as Difficulty,
      equipment: (fields[6] as List).cast<String>(),
      videoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.equipment)
      ..writeByte(7)
      ..write(obj.videoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WodExerciseAdapter extends TypeAdapter<WodExercise> {
  @override
  final int typeId = 3;

  @override
  WodExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WodExercise(
      exercise: fields[0] as Exercise,
      reps: fields[1] as int,
      weight: fields[2] as double?,
      duration: fields[3] as int?,
      distance: fields[4] as int?,
      calories: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WodExercise obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.distance)
      ..writeByte(5)
      ..write(obj.calories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WodExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
