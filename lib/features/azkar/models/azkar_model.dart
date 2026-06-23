import "package:adhan/adhan.dart";
import "package:flutter/material.dart";

import "../../../constant.dart";
import "../../../core/helpers/hive_helper.dart";
import "../data/azkar_data.dart";

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

  bool isInRange(DateTime now, PrayerTimes prayerTimes) {
    switch (type) {
      // أذكار الاستيقاظ
      case AzkarType.wakeUp:
        final DateTime wakeUpTime =
            HiveHelper.getDataByKey(kBoxSettings, "wakeUpTime") ??
            prayerTimes.fajr.add(const Duration(minutes: -30));
        return now.difference(wakeUpTime).inMinutes.abs() <= 30;

      // أذكار الصباح - من الفجر الى الظهر
      case AzkarType.morning:
        final start = prayerTimes.fajr.add(const Duration(minutes: 30));
        final end = prayerTimes.dhuhr;
        return now.isAfter(start) && now.isBefore(end);

      // أذكار المساء - من العصر الى المغرب
      case AzkarType.evening:
        final start = prayerTimes.asr.add(const Duration(minutes: 30));
        final end = prayerTimes.isha;
        return now.isAfter(start) && now.isBefore(end);

      // أذكار النوم - من العشاء الى الفجر
      case AzkarType.sleep:
        final int nowMinutes = now.hour * 60 + now.minute;
        final int ishaMinutes =
            prayerTimes.isha.hour * 60 + prayerTimes.isha.minute;
        final int fajrMinutes =
            prayerTimes.fajr.hour * 60 + prayerTimes.fajr.minute;

        return nowMinutes >= ishaMinutes || nowMinutes < fajrMinutes;
      default:
        return false;
    }
  }
}
