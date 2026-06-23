import "package:adhan/adhan.dart";
import "package:flutter/material.dart";

import "../../../constant.dart";
import "../../../core/helpers/hive_helper.dart";
import "../data/azkar_data.dart";
import "zekr_model.dart";

enum AzkarType { wakeUp, morning, evening, afterPrayer, tasabeeh, sleep }

class Azkar {
  final String title;
  final String? description;
  final AzkarType type;
  final bool? isDone;
  final List<Zekr> data;

  Azkar({
    required this.title,
    required this.data,
    this.description = AzkarConstants.taha130,
    required this.type,
    this.isDone,
  });

  TimeOfDay getTime(PrayerTimes prayerTimes) {
    switch (type) {
      case AzkarType.wakeUp:
        final DateTime wakeUp =
            HiveHelper.getDataByKey(kBoxSettings, "wakeUpTime") ??
            prayerTimes.fajr.add(const Duration(minutes: -30));
        return TimeOfDay.fromDateTime(wakeUp);
      case AzkarType.morning:
        return TimeOfDay.fromDateTime(
          prayerTimes.fajr.add(const Duration(minutes: 30)),
        );
      case AzkarType.evening:
        return TimeOfDay.fromDateTime(
          prayerTimes.asr.add(const Duration(minutes: 30)),
        );
      case AzkarType.sleep:
        return TimeOfDay.fromDateTime(prayerTimes.isha);
      default:
        return TimeOfDay.now();
    }
  }
}
