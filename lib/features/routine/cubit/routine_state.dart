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

  Task? get currentTask => tasks.firstWhereOrNull(
    (t) => t.startTime.isBefore(now) && t.endTime.isAfter(now),
  );

  RoutineLoaded({required this.tasks});
}
