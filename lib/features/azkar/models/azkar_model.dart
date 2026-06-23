import "package:adhan/adhan.dart";
import "package:flutter/material.dart";

import "../../../constant.dart";
import "../../../core/extensions/date_time_extensions.dart";
import "../../../core/helpers/hive_helper.dart";
import "../data/azkar_data.dart";

enum AzkarType { wakeUp, morning, evening, afterPrayer, tasabeeh, sleep }

class Azkar {
  final String title;
  final IconData? icon;
  final String? description;
  final AzkarType type;
  final bool? isDone;
  final List<Zekr> data;

  Azkar({
    required this.title,
    this.icon,
    required this.data,
    this.description = AzkarConstants.taha130,
    required this.type,
    this.isDone,
  });

  int get durationInMinutes => (() {
    // 1. حساب إجمالي عدد الكلمات المقروءة (عدد كلمات الذكر × عدد التكرارات)
    final totalWords = data
        .map((z) {
          // حساب عدد الكلمات عبر تقسيم النص بناءً على المسافات
          final wordCount = z.content.trim().split(RegExp(r"\s+")).length;
          return wordCount * z.count;
        })
        .reduce((value, element) => value + element);

    // 2. القسمة على متوسط سرعة القراءة (مثلاً: 130 كلمة في الدقيقة)
    // استخدمنا .ceil() لتقريب الكسر لأقرب دقيقة كاملة (حتى لا تظهر 0 دقيقة للأذكار القصيرة)
    final calculatedDuration = (totalWords / 130).ceil();

    // 3. التأكد من أن المدة لا تقل عن دقيقة واحدة على الأقل
    return calculatedDuration < 1 ? 1 : calculatedDuration;
  })();

  TimeOfDay getTime(PrayerTimes prayerTimes) {
    switch (type) {
      case AzkarType.wakeUp:
        final DateTime wakeUp =
            HiveHelper.getDataByKey(kBoxSettings, "wakeUpTime") ??
            prayerTimes.fajr.add(const Duration(minutes: -30));
        return wakeUp.toTimeOfDay;
      case AzkarType.morning:
        return prayerTimes.fajr.add(const Duration(hours: 1)).toTimeOfDay;
      case AzkarType.evening:
        return prayerTimes.asr.add(const Duration(minutes: 30)).toTimeOfDay;
      case AzkarType.sleep:
        return prayerTimes.isha.toTimeOfDay;
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
