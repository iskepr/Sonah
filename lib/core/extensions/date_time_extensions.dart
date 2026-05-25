import "package:intl/intl.dart";

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
