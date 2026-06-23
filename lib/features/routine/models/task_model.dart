import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
part "task_model.g.dart";

@HiveType(typeId: 0)
enum TaskType {
  @HiveField(0)
  normal,
  @HiveField(1)
  prayer,
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  onTime,
}

@HiveType(typeId: 2)
enum TaskMode {
  @HiveField(0)
  normal,
  @HiveField(1)
  focus,
  @HiveField(2)
  prayer,
  @HiveField(3)
  work,
  @HiveField(4)
  sleep,
  @HiveField(5)
  relax,
  @HiveField(6)
  game,
  @HiveField(7)
  study,
}

@HiveType(typeId: 3)
class Task {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final TaskType type;

  @HiveField(4)
  final TaskPriority priority;

  @HiveField(5)
  final TaskMode mode;

  @HiveField(6)
  final List<String>? appId; // لو فاضي مفيش تطبيقات ولو null كلو هيظهر

  @HiveField(7)
  final List<String>? days; // [1,3,5,7] - لو ب null هيكون لمرة واده ولا يتكرر

  @HiveField(8)
  final TimeOfDay startTime;

  @HiveField(9)
  final TimeOfDay? endTime;

  @HiveField(10)
  final List<Task> subTasks;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.type = TaskType.normal,
    this.priority = TaskPriority.medium,
    this.mode = TaskMode.normal,
    this.appId,
    this.days,
    required this.startTime,
    this.endTime,
    this.subTasks = const [],
  });
}
