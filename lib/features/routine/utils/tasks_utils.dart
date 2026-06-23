import "package:flutter/material.dart";

import "../../../core/extensions/date_time_extensions.dart";
import "../models/task_model.dart";

class TaskChain {
  DateTime _currentCursor;

  TaskChain(this._currentCursor);

  // دالة بتضيف مهمة وتعدل المؤشر بناءً على مدتها واتجاهها
  Task append({
    required String title,
    IconData? icon,
    required String description,
    required int durationInMinutes,
    TaskPriority priority = TaskPriority.medium,
    int delayInMinutes = 5,
    List<String>? appsIds,
    TaskMode mode = TaskMode.normal,
    bool isBefore =
        false, // لو true يبقى المهمة دي قبل التوقيت الحالي (قبل الصلاة مثلاً)
  }) {
    if (isBefore) {
      // 1. لو قبل الصلاة، بنرجع لورا بمقدار المدة + الـ delay
      final startTimeDateTime = _currentCursor.subtract(
        Duration(minutes: durationInMinutes + delayInMinutes),
      );

      // مش هنحرك الـ _currentCursor الأساسي عشان الـ Chain اللي بعد الصلاة تفضل مظبوطة من وقت الأذان
      return Task(
        title: title,
        description: description,
        priority: priority,
        mode: mode,
        startTime: startTimeDateTime.toTimeOfDay,
        durationInMinutes: durationInMinutes,
        appsIds: appsIds,
      );
    } else {
      // الـ Logic القديم بتاعك زي ما هو لـ "بعد الصلاة" أو "بعد الاستيقاظ"

      // 1. بنزود الـ delay لو فيه وقت راحة قبل المهمة
      _currentCursor = _currentCursor.add(Duration(minutes: delayInMinutes));

      // 2. ده وقت بداية المهمة الحالية
      final startTime = _currentCursor.toTimeOfDay;

      // 3. بنحرك المؤشر لنهاية المهمة الحالية عشان اللي بعدها تبدأ منه
      _currentCursor = _currentCursor.add(Duration(minutes: durationInMinutes));

      return Task(
        title: title,
        icon: icon,
        description: description,
        priority: priority,
        mode: mode,
        startTime: startTime,
        durationInMinutes: durationInMinutes,
        appsIds: appsIds,
      );
    }
  }
}
