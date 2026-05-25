import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key, required this.prayerTimes});
  final PrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text("${l10n.fajr} ${prayerTimes.fajr.toTimeOnly()}"),
          leading: const Icon(LucideIcons.sunMoon),
        ),
        ListTile(
          title: Text("${l10n.sunrise} ${prayerTimes.sunrise.toTimeOnly()}"),
          leading: const Icon(LucideIcons.sunrise),
        ),
        ListTile(
          title: Text("${l10n.dhuhr} ${prayerTimes.dhuhr.toTimeOnly()}"),
          leading: const Icon(LucideIcons.sun),
        ),
        ListTile(
          title: Text("${l10n.asr} ${prayerTimes.asr.toTimeOnly()}"),
          leading: const Icon(LucideIcons.sunDim),
        ),
        ListTile(
          title: Text("${l10n.maghrib} ${prayerTimes.maghrib.toTimeOnly()}"),
          leading: const Icon(LucideIcons.sunset),
        ),
        ListTile(
          title: Text("${l10n.isha} ${prayerTimes.isha.toTimeOnly()}"),
          leading: const Icon(LucideIcons.moon),
        ),
      ],
    );
  }
}
