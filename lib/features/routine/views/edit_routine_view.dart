import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../athan/extensions/athan_extenstion.dart";
import "../../azkar/data/azkar_data.dart";
import "../models/task_model.dart";
import "widgets/task_view.dart";

class EditRoutineView extends StatelessWidget {
  const EditRoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerTimes = context.prayerTimes!;
    final List<Task> tasks = [
      ...List.generate(kPrayers.length, (index) {
        final prayer = kPrayers[index];
        final prayerTime = prayerTimes.timeForPrayer(prayer) ?? DateTime.now();
        final azkarAfterPrayer = AzkarConstants.afterPrayer;

        return Task(
          id: index,
          title: "${l10n.prayer.removeEl} ${prayer.prayerName}",
          description:
              "إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا | النساء: 103",
          priority: TaskPriority.onTime,
          mode: TaskMode.prayer,
          startTime: TimeOfDay.fromDateTime(prayerTime),
          subTasks: [
            Task(
              id: index + 100,
              title: azkarAfterPrayer.title,
              description: azkarAfterPrayer.description,
              startTime: TimeOfDay.fromDateTime(
                prayerTime.add(const Duration(minutes: 10)),
              ),
            ),
          ],
        );
      }),
      ...kAzkar.where((a) => a != AzkarType.afterPrayer).map((azkarType) {
        final azkar = azkarType.azkarByType;
        return Task(
          id: azkar.type.index + 200,
          title: azkar.title,
          description: azkar.description,
          priority: TaskPriority.high,
          mode: TaskMode.normal,
          startTime: azkar.getTime(prayerTimes),
        );
      }),
    ];
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.check),
          onPressed: () => context.close(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskView(task: tasks[index]),
            ),
          ),
        ],
      ),
    );
  }
}
