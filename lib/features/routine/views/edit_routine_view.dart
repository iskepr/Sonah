import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/theme/colors.dart";
import "../models/task_entity.dart";

class EditRoutineView extends StatelessWidget {
  const EditRoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TaskEntity> tasks = [
      TaskEntity(
        id: 1,
        title: "Task 1",
        description: "Description 1",
        priority: TaskPriority.low,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
      TaskEntity(
        id: 1,
        title: "Task 2",
        description: "Description 2",
        priority: TaskPriority.medium,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
      TaskEntity(
        id: 1,
        title: "Task 3",
        description: "Description 3",
        priority: TaskPriority.high,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.check),
          onPressed: () => context.close(),
        ),
      ),
      body: Column(
        children: [
          const Text("EditRoutineView"),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
                final task = tasks[index];
                return Card(
                  color: context.colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(task.title),
                          Text(task.description ?? ""),
                          Text(task.priority.name),
                        ],
                      ),
                      Row(
                        spacing: kSmallPadding,
                        children: [
                          Text(task.startTime.timeOnly()),
                          Text(task.endTime?.timeOnly() ?? ""),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
