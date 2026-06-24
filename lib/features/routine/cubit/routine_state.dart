import "package:flutter/material.dart";

import "../../azkar/cubit/azkar_cubit.dart";
import "../models/task_model.dart";

class RoutineState {}

class RoutineInitial extends RoutineState {}

class RoutineError extends RoutineState {}

class RoutineLoading extends RoutineState {}

class RoutineLoaded extends RoutineState {
  final List<Task> tasks;

  TimeOfDay get now => TimeOfDay.now();

  // Task? get currentTask => tasks.firstWhereOrNull(
  //   (t) => t.startTime.isBefore(now) && t.endTime.isAfter(now),
  // );

  Task? get currentTask => tasks.firstWhereOrNull((t) {
    final now = TimeOfDay.now();
    final nowInMinutes = now.hour * 60 + now.minute;
    final startTimeInMinutes = t.startTime.hour * 60 + t.startTime.minute;
    final endTimeInMinutes = t.endTime.hour * 60 + t.endTime.minute;

    // في حالة بداية ونهاية المهة في نفس اليوم
    if (startTimeInMinutes <= endTimeInMinutes) {
      return nowInMinutes >= startTimeInMinutes &&
          nowInMinutes < endTimeInMinutes;
    }
    // في حالة بداية المهمة في يوم ونهايتها لليوم التاني
    else {
      return nowInMinutes >= startTimeInMinutes ||
          nowInMinutes < endTimeInMinutes;
    }
  });

  RoutineLoaded({required this.tasks});
}
