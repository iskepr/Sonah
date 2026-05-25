import "package:intl/intl.dart";

extension DateTimeFormat on DateTime {
  String toTimeOnly({bool showPeriod = true, bool isArabic = true}) {
    final e = isUtc ? toLocal() : this;
    final h = e.hour % 12 == 0 ? 12 : e.hour % 12;

    final p = e.hour >= 12 ? (isArabic ? "م" : "PM") : (isArabic ? "ص" : "AM");

    return showPeriod
        ? "$h:${e.minute.toString().padLeft(2, "0")} $p"
        : "$h:${e.minute.toString().padLeft(2, "0")}";
  }

  String get dateOnlyy {
    final e = isUtc ? toLocal() : this;
    final now = DateTime.now();
    final String yearSuffix = now.year == e.year
        ? ""
        : "/${e.year.toString().substring(2)}";
    return "${e.day}/${e.month}$yearSuffix";
  }

  String get dateOnly {
    final e = isUtc ? toLocal() : this;
    final now = DateTime.now();
    return DateFormat("d MMMM ${now.year == e.year ? "" : "yy"}").format(e);
  }

  String get fullDateTime => "$dateOnly $toTimeOnly";

  String get smartFormat {
    final e = isUtc ? toLocal() : this;
    final now = DateTime.now();
    if (e.day == now.day && e.month == now.month && e.year == now.year) {
      return toTimeOnly();
    }
    return dateOnly;
  }

  String get fullDate {
    final e = isUtc ? toLocal() : this;
    return "${e.day}/${e.month}/${e.year}";
  }

  String get fullSmartFormat {
    final e = isUtc ? toLocal() : this;
    final now = DateTime.now();
    if (e.day == now.day && e.month == now.month && e.year == now.year) {
      return toTimeOnly();
    }
    return fullDateTime;
  }
}

class DateTimeHelper {
  static DateTime get now => DateTime.now().toUtc();

  static String get nowIso => now.toIso8601String();

  static String afterMinutesIso(int minutes) {
    return now.add(Duration(minutes: minutes)).toIso8601String();
  }
}

extension TimeExtension on String {
  int? get weekDayNumber {
    return int.tryParse(this);
  }

  String get weekDayName {
    final index = weekDayNumber;
    if (index == null) return "";
    return DateFormat.EEEE().format(
      DateTime(2024, 1, (index == 1) ? 7 : index - 1),
    );
  }

  DateTime get timeFromHours {
    if (isEmpty || this == "null") return DateTime(2024, 1, 1);
    final time = split(":");
    if (time.length < 2) return DateTime(2024, 1, 1);

    final hour = int.tryParse(time[0]) ?? 0;
    final minute = int.tryParse(time[1]) ?? 0;

    return DateTime(2024, 1, 1, hour, minute);
  }
}

extension DateTimeWeekUtils on DateTime {
  /// بيجيب ترتيب اليوم في الأسبوع بناءً على إن الأسبوع يبدأ من الأحد
  /// الأحد = 1، الإثنين = 2، ... السبت = 7
  int get sundayFirstWeekday {
    return (weekday % 7) + 1;
  }

  /// بيجيب رقم الأسبوع الحالي في السنة (من 1 لـ 53) بناءً على إن الأسبوع يبدأ من الأحد
  int get weekOfYear {
    final DateTime firstDayOfYear = DateTime(year, 1, 1);

    // إزاحة أول يوم في السنة بناءً على الأسبوع الأحد
    final int firstDayShift = firstDayOfYear.weekday % 7;

    // الأيام اللي عدت من أول السنة لحد التاريخ ده (بداية من منتصف الليل)
    final DateTime currentMidnight = DateTime(year, month, day);
    final int daysPassed = currentMidnight.difference(firstDayOfYear).inDays;

    return ((daysPassed + firstDayShift) / 7).floor() + 1;
  }
}

extension CountdownExtension on DateTime {
  String differenceToFormattedString([DateTime? fromTime]) {
    final start = fromTime ?? DateTime.now();

    final duration = difference(start);

    if (duration.isNegative || duration.inSeconds <= 0) {
      return "00:00:00";
    }

    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");

    return "${hours == 0 ? "" : "$hours:"}$minutes:$seconds";
  }
}
