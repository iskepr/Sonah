import "../models/task_model.dart";

class RoutineState {}

class RoutineInitial extends RoutineState {}

class RoutineError extends RoutineState {}

class RoutineLoading extends RoutineState {}

class RoutineLoaded extends RoutineState {
  final List<Task> tasks;

  RoutineLoaded({required this.tasks});
}
