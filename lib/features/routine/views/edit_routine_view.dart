import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../athan/extensions/athan_extenstion.dart";
import "../../azkar/data/azkar_data.dart";
import "../models/task_model.dart";
import "../utils/tasks_utils.dart";
import "widgets/task_view.dart";

class EditRoutineView extends StatelessWidget {
  const EditRoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerTimes = context.prayerTimes!;

    final fajrChain = TaskChain(prayerTimes.fajr);
    final dhuhrChain = TaskChain(prayerTimes.dhuhr);
    final asrChain = TaskChain(prayerTimes.asr);
    final maghribChain = TaskChain(prayerTimes.maghrib);
    final ishaChain = TaskChain(prayerTimes.isha);

    final List<Task> tasks = [
      ...List.generate(kPrayers.length, (index) {
        final prayer = kPrayers[index];
        final prayerTime =
            prayerTimes.timeForPrayer(prayer) ?? DateTimeHelper.now;
        final azkarAfterPrayer = AzkarConstants.getPrayerAzkar(prayer);

        return Task(
          title: "${l10n.prayer.removeEl} ${prayer.prayerName}",
          icon: prayer.prayerIcon,
          description:
              "إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا | النساء: 103",
          priority: TaskPriority.onTime,
          mode: TaskMode.prayer,
          startTime: prayerTime.toTimeOfDay,
          durationInMinutes: kPrayerDurationInMinutes,
          subTasks: [
            Task(
              title: azkarAfterPrayer.title,
              icon: azkarAfterPrayer.icon,
              description: azkarAfterPrayer.description,
              priority: TaskPriority.high,
              mode: TaskMode.prayer,
              startTime: prayerTime
                  .add(const Duration(minutes: kPrayerDurationInMinutes))
                  .toTimeOfDay,
              durationInMinutes: azkarAfterPrayer.durationInMinutes,
            ),
          ],
        );
      }),
      ...kAzkarTyps.where((a) => a != AzkarType.afterPrayer).map((azkarType) {
        final azkar = azkarType.azkarByType;
        return Task(
          title: azkar.title,
          icon: azkar.icon,
          description: azkar.description,
          priority: TaskPriority.high,
          mode: TaskMode.prayer,
          startTime: azkar.getTime(prayerTimes),
          durationInMinutes: azkar.durationInMinutes,
        );
      }),

      fajrChain.append(
        title: "المشي بعيداً عن المشتتات",
        icon: LucideIcons.leaf,
        description:
            "امشي على الأقل 15 دقيقة بدون هاتف، امشِ بوقار، استعد حضورك الذهني، وتخلص من ضجيج الإشعارات لتستعيد سلامك النفسي.",
        delayInMinutes: kPrayerDurationInMinutes + 5,
        durationInMinutes: 15,
      ),

      fajrChain.append(
        title: "ورد القرآن",
        icon: LucideIcons.bookOpenText,
        description:
            "إِنَّ هَـذَا الْقُرْآنَ يِهْدِي لِلَّتِي هِيَ أَقْوَمُ وَيُبَشِّرُ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْراً كَبِيراً | الإسراء: 9",
        priority: TaskPriority.high,
        appsIds: ["com.blink22.fajr"],
        durationInMinutes: 30,
      ),

      fajrChain.append(
        title: "تمارين بسيطة",
        icon: LucideIcons.dumbbell,
        description:
            "أبدا يومك بتمارين بسيطة. التمارين تساعد على التركيز وابتكار افكار جديدة.",
        durationInMinutes: 15,
      ),

      fajrChain.append(
        title: "الإفطار",
        icon: LucideIcons.eggFried,
        description:
            "تناول الإفطار لتمد جسمك بالطاقة لبدأ يومك بنشاط وأهم شئ تناول الطعام من دون مشاهدة شئ",
        priority: TaskPriority.high,
        durationInMinutes: 20,
      ),

      fajrChain.append(
        title: "كتابة المهام اليوم",
        icon: LucideIcons.clipboardList,
        description:
            "يُفضل كتابة المهام لهذا اليوم لتساعدك في تنظيم اليوم. و تحسين الانتاجية.",
        durationInMinutes: 10,
      ),

      // --- Dhuhr Chain ---
      dhuhrChain.append(
        title: "الذهاب للجيم",
        icon: LucideIcons.dumbbell,
        priority: TaskPriority.high,
        description: "وقت الـ Workout وتفريغ الطاقة في الجيم.",
        durationInMinutes: 60,
      ),

      dhuhrChain.append(
        title: "لعبة تركيز",
        icon: LucideIcons.brain,
        description: "لعب لعبة تركيز وتنشيط عقلي مثل الشطرنج أو تطبيق شعلة.",
        durationInMinutes: 15,
      ),

      // --- Asr Chain ---
      asrChain.append(
        title: "الغداء",
        icon: LucideIcons.utensils,
        description:
            "تغذية الجسم بوجبة الغداء، وبرضه من غير ما تتفرج على أي حاجة وأنت بتأكل.",
        priority: TaskPriority.high,
        durationInMinutes: 30,
      ),

      // --- Maghrib Chain ---
      maghribChain.append(
        title: "وقت العائلة والأصدقاء",
        icon: LucideIcons.users,
        description:
            "قضاء وقت اجتماعي ممتع مع العائلة أو الأصدقاء لتجديد النشاط والود.",
        durationInMinutes: 120,
      ),

      // --- Isha Chain ---
      ishaChain.append(
        title: "الذهاب للنوم",
        icon: LucideIcons.moon,
        description:
            "الاستعداد للنوم والاسترخاء تماماً للحصول على راحة كافية ليوم جديد.",
        priority: TaskPriority.high,
        durationInMinutes: 20,
      ),
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
