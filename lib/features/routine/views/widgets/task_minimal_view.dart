import "package:flutter/material.dart";

import "../../../../constant.dart";
import "../../models/task_model.dart";

class TaskMinimalView extends StatelessWidget {
  const TaskMinimalView({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: kSmallPadding,
      children: [
        if (task.icon != null)
          Icon(task.icon, size: kMediumFont * 1.5, color: task.priority.color),
        Text(task.title, style: const TextStyle(fontSize: kMediumFont)),
        Text(
          task.priority.label,
          style: TextStyle(
            fontSize: kSmallFont,
            fontWeight: FontWeight.bold,
            color: task.priority.color,
          ),
        ),
      ],
    );
  }
}
