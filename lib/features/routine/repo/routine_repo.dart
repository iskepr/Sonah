import "package:flutter/material.dart";

import "../../../core/extensions/date_time_extensions.dart";
import "../models/task_model.dart";

class RoutineRepo {
  static void sortTasks(List<Task> tasks) =>
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

  static List<Task> processDynamicTimeline(List<Task> tasks) {
    final TimeOfDay now = TimeOfDay.now();

    sortTasks(tasks);

    final List<Task> finalTasks = [];
    TimeOfDay? nextShiftedStartTime;

    for (var task in tasks) {
      if (task.startTime.isAfter(now)) {
        if (task.priority == TaskPriority.onTime ||
            task.priority == TaskPriority.strict) {
          finalTasks.add(task);

          final TimeOfDay taskEndTime = task.startTime.toDateTime
              .add(Duration(minutes: task.durationInMinutes))
              .toTimeOfDay;

          if (nextShiftedStartTime != null &&
              nextShiftedStartTime.isBefore(taskEndTime)) {
            nextShiftedStartTime = taskEndTime;
          }
        }
        // مهمة هامة
        else {
          if (nextShiftedStartTime != null) {
            final updatedTask = task.copyWith(startTime: nextShiftedStartTime);
            finalTasks.add(updatedTask);

            nextShiftedStartTime = nextShiftedStartTime.toDateTime
                .add(Duration(minutes: task.durationInMinutes))
                .toTimeOfDay;
          } else {
            finalTasks.add(task);
          }
        }
      }
      // في حالة انتهاء وقت المهمة
      else {
        // لو مخمة مهمة هتترحل للوقت الحالي
        if (task.priority == TaskPriority.high ||
            task.priority == TaskPriority.onTime) {
          final TimeOfDay actualStart = nextShiftedStartTime ?? now;

          final updatedTask = task.copyWith(startTime: actualStart);
          finalTasks.add(updatedTask);

          nextShiftedStartTime = actualStart.toDateTime
              .add(Duration(minutes: task.durationInMinutes))
              .toTimeOfDay;
        }
        // لو وقتها عدى خلاص راحت عليك وي السفر
        else if (task.priority == TaskPriority.strict) {
          debugPrint("المهمة الدقيقة ${task.title} فات وقتها وطارت أوتوماتيك.");
        }
        // لو مهمة مش مهمة هتطبير
      }
    }

    sortTasks(finalTasks);
    return finalTasks;
  }
}
