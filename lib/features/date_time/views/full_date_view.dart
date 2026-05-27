import "package:flutter/material.dart";
import "package:hijri/hijri_calendar.dart";
import "package:intl/intl.dart";

import "../../../constant.dart";

class FullDateView extends StatefulWidget {
  const FullDateView({super.key});

  @override
  State<FullDateView> createState() => _FullDateViewState();
}

class _FullDateViewState extends State<FullDateView> {
  bool isHijri = true;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    HijriCalendar.setLocal(kAppLang);
    final today = HijriCalendar.now();

    const dateFormat = "dd MMMM yyyy";

    return GestureDetector(
      onTap: () => setState(() => isHijri = !isHijri),
      child: Row(
        children: [
          Text(
            "${today.dayWeName}, ",
            style: const TextStyle(
              fontSize: kMediumFont,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            isHijri
                ? today.format(
                    today.hYear,
                    today.hMonth,
                    today.hDay,
                    dateFormat,
                  )
                : DateFormat(dateFormat).format(now),
            style: const TextStyle(
              fontSize: kSmallFont,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
