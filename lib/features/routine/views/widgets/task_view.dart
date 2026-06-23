import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../../../constant.dart";
import "../../../../core/extensions/date_time_extensions.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/material.dart";
import "../../models/task_model.dart";

class TaskView extends StatelessWidget {
  const TaskView({super.key, required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(kSmallBorderRadius),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: kSmallPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان و الالهمية
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  spacing: kSmallPadding,
                  children: [
                    if (task.icon != null)
                      Icon(
                        task.icon,
                        size: kMediumFont * 1.5,
                        color: task.priority.color,
                      ),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: kMediumFont,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildPriorityBadge(context, task.priority),
            ],
          ),

          // الوصف
          if (task.description != null && task.description!.isNotEmpty) ...[
            Text(
              task.description!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const Divider(thickness: 0.5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الوقت
              Wrap(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: kMediumFont,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.startTime.timeOnly(),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "  ←  ",
                    style: TextStyle(color: context.colorScheme.outline),
                  ),
                  Text(
                    task.endTime.timeOnly(),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    " ~${task.duration.format}",
                    style: TextStyle(
                      color: context.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              Row(
                spacing: 6,
                children: [
                  // if (task.days != null)
                  if (task.subTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "المهام: ${task.subTasks.length}",
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (task.subTasks.isNotEmpty) ...[
            const Divider(thickness: 0.5),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: kSmallPadding),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: task.subTasks.length,
                itemBuilder: (context, index) => Column(
                  spacing: kSmallPadding,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (task.subTasks[index].icon != null)
                              Icon(
                                task.subTasks[index].icon,
                                size: kMediumFont * 1.5,
                                color: task.subTasks[index].priority.color,
                              ),
                            Text(
                              task.subTasks[index].title,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              " ~${task.subTasks[index].duration.format}",
                              style: TextStyle(
                                color: context.colorScheme.outline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        _buildPriorityBadge(
                          context,
                          task.subTasks[index].priority,
                        ),
                      ],
                    ),
                    Text(
                      task.subTasks[index].description!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, TaskPriority priority) {
    return MyMaterial(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: priority.color.withOpacity(0.12),

      child: Text(
        priority.label,
        style: context.textTheme.labelSmall?.copyWith(
          color: priority.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
