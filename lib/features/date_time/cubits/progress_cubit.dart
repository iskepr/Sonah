import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";

enum ProgressMode {
  day,
  week,
  month,
  year,
} // رتبتهم تصاعدي عشان اللفة تبدأ من اليوم

class ProgressState {}

class ProgressInitial extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final String now;
  final double pers;
  ProgressLoaded(this.now, this.pers);
}

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit() : super(ProgressInitial());

  DateTime get now => DateTime.now();

  ProgressMode currentMode = ProgressMode.day;

  void getProg() => getProgByMode(currentMode);

  void toggleMode() {
    const modes = ProgressMode.values;
    final nextIndex = (currentMode.index + 1) % modes.length;
    currentMode = modes[nextIndex];
    getProgByMode(currentMode);
  }

  void getProgByMode(ProgressMode mode) {
    final DateTime todayMidnight = DateTime(now.year, now.month, now.day);

    if (mode == ProgressMode.year) {
      final int year = now.year;
      final DateTime firstDayInYear = DateTime(year, 1, 1);
      final DateTime firstDayInNextYear = DateTime(year + 1, 1, 1);

      final int yearDays = firstDayInNextYear.difference(firstDayInYear).inDays;
      final int defDays = todayMidnight.difference(firstDayInYear).inDays;

      safeEmit(
        ProgressLoaded("${l10n.year} $year", (defDays / yearDays) * 100),
      );
    } else if (mode == ProgressMode.month) {
      final int month = now.month;
      final int monthDays = DateTime(now.year, month + 1, 0).day;

      safeEmit(
        ProgressLoaded("${l10n.month} $month", (now.day / monthDays) * 100),
      );
    } else if (mode == ProgressMode.week) {
      final int weekDay = now.sundayFirstWeekday;
      final int weekOfYear = now.weekOfYear;
      const int weekDays = 7;

      safeEmit(
        ProgressLoaded("${l10n.week} $weekOfYear", (weekDay / weekDays) * 100),
      );
    } else if (mode == ProgressMode.day) {
      final double passedHours =
          now.hour + (now.minute / 60) + (now.second / 3600);
      const double totalHoursInDay = 24.0;

      final DateTime firstDayInYear = DateTime(now.year, 1, 1);
      final int dayOfYear = todayMidnight.difference(firstDayInYear).inDays + 1;

      safeEmit(
        ProgressLoaded(
          "${l10n.day} $dayOfYear",
          (passedHours / totalHoursInDay) * 100,
        ),
      );
    }
  }
}
