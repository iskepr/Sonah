enum TaskType { normal, prayer }

enum TaskPriority { low, medium, high, onTime }

enum TaskMode { normal, focus, prayer, work, sleep, relax, game, study }

class TaskEntity {
  final int id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskMode mode;
  final List<String> appId; // لو فاضي مفيش اي تطبيقات هتظهر وقت التاسك ده
  final List<String>? days; // [1,3,5,7] - لو ب null هيكون لمرة واده ولا يتكرر
  final DateTime startTime;
  final DateTime? endTime;

  TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.mode = TaskMode.normal,
    this.appId = const [],
    this.days,
    required this.startTime,
    this.endTime,
  });
}
