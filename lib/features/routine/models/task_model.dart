import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

import "../../../core/extensions/date_time_extensions.dart";
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
  low("منخفظة", Colors.green),
  @HiveField(1)
  medium("متوسطة", Colors.orange),
  @HiveField(2)
  high("هامة", Colors.deepOrange),
  @HiveField(3)
  onTime("على الوقت", Colors.red);

  final String label;
  final Color color;
  const TaskPriority(this.label, this.color);
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
  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(12)
  final IconData? icon;

  @HiveField(3)
  final TaskType type;

  @HiveField(4)
  final TaskPriority priority;

  @HiveField(5)
  final TaskMode mode;

  @HiveField(6)
  final List<String>? appsIds; // لو فاضي مفيش تطبيقات ولو null كلو هيظهر

  @HiveField(7)
  final List<String>? days; // [1,3,5,7] - لو ب null هيكون لمرة واده ولا يتكرر

  @HiveField(8)
  final TimeOfDay startTime;

  @HiveField(9)
  final TimeOfDay endTime;

  @HiveField(10)
  final int durationInMinutes;

  @HiveField(11)
  final List<Task> subTasks;

  Task({
    required this.title,
    this.description,
    this.icon,
    this.type = TaskType.normal,
    this.priority = TaskPriority.medium,
    this.mode = TaskMode.normal,
    this.appsIds,
    this.days,
    required this.startTime,
    TimeOfDay? endTime,
    int? durationInMinutes,
    this.subTasks = const [],
  }) : assert(
         endTime != null || durationInMinutes != null,
         "يجب تحديد إما وقت الانتهاء (endTime) أو مدة المهمة (durationInMinutes). لا يمكن تركهما معاً فارغين.",
       ),
       durationInMinutes =
           (durationInMinutes ??
               (endTime != null
                   ? endTime.toDateTime
                         .difference(startTime.toDateTime)
                         .inMinutes
                   : 5)) +
           subTasks.fold<int>(
             0,
             (sum, subTask) => sum + subTask.durationInMinutes,
           ),

       endTime =
           endTime ??
           startTime.toDateTime
               .add(
                 Duration(
                   minutes:
                       (durationInMinutes ??
                           (endTime != null
                               ? endTime.toDateTime
                                     .difference(startTime.toDateTime)
                                     .inMinutes
                               : 5)) +
                       subTasks.fold<int>(
                         0,
                         (sum, subTask) => sum + subTask.durationInMinutes,
                       ),
                 ),
               )
               .toTimeOfDay;

  Duration get duration => Duration(minutes: durationInMinutes);
}
