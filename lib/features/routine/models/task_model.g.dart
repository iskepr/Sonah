// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as TaskType,
      priority: fields[4] as TaskPriority,
      mode: fields[5] as TaskMode,
      appId: (fields[6] as List?)?.cast<String>(),
      days: (fields[7] as List?)?.cast<String>(),
      startTime: fields[8] as DateTime,
      endTime: fields[9] as DateTime?,
      subTasks: (fields[10] as List).cast<Task>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.mode)
      ..writeByte(6)
      ..write(obj.appId)
      ..writeByte(7)
      ..write(obj.days)
      ..writeByte(8)
      ..write(obj.startTime)
      ..writeByte(9)
      ..write(obj.endTime)
      ..writeByte(10)
      ..write(obj.subTasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 0;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.normal;
      case 1:
        return TaskType.prayer;
      default:
        return TaskType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.normal:
        writer.writeByte(0);
        break;
      case TaskType.prayer:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 1;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.onTime;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
      case TaskPriority.onTime:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskModeAdapter extends TypeAdapter<TaskMode> {
  @override
  final int typeId = 2;

  @override
  TaskMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskMode.normal;
      case 1:
        return TaskMode.focus;
      case 2:
        return TaskMode.prayer;
      case 3:
        return TaskMode.work;
      case 4:
        return TaskMode.sleep;
      case 5:
        return TaskMode.relax;
      case 6:
        return TaskMode.game;
      case 7:
        return TaskMode.study;
      default:
        return TaskMode.normal;
    }
  }

  @override
  void write(BinaryWriter writer, TaskMode obj) {
    switch (obj) {
      case TaskMode.normal:
        writer.writeByte(0);
        break;
      case TaskMode.focus:
        writer.writeByte(1);
        break;
      case TaskMode.prayer:
        writer.writeByte(2);
        break;
      case TaskMode.work:
        writer.writeByte(3);
        break;
      case TaskMode.sleep:
        writer.writeByte(4);
        break;
      case TaskMode.relax:
        writer.writeByte(5);
        break;
      case TaskMode.game:
        writer.writeByte(6);
        break;
      case TaskMode.study:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
