import "package:flutter/material.dart";
import "package:hijri/hijri_calendar.dart";

class HijriDateView extends StatelessWidget {
  const HijriDateView({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.now();
    HijriCalendar.setLocal("ar");
    return Text(
      today.format(today.hYear, today.hMonth, today.hDay, "DDDD, dd MMMM yyyy"),
    );
  }
}
