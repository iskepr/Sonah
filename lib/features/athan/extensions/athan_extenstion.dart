import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";

extension AthanExtension on Prayer {
  String get prayerName {
    switch (this) {
      case Prayer.fajr:
        return l10n.fajr;
      case Prayer.sunrise:
        return l10n.sunrise;
      case Prayer.dhuhr:
        return l10n.dhuhr;
      case Prayer.asr:
        return l10n.asr;
      case Prayer.maghrib:
        return l10n.maghrib;
      case Prayer.isha:
        return l10n.isha;
      default:
        return "";
    }
  }

  IconData get prayerIcon {
    switch (this) {
      case Prayer.fajr:
        return LucideIcons.sunMoon;
      case Prayer.sunrise:
        return LucideIcons.sunrise;
      case Prayer.dhuhr:
        return LucideIcons.sun;
      case Prayer.asr:
        return LucideIcons.sunMedium;
      case Prayer.maghrib:
        return LucideIcons.sunset;
      case Prayer.isha:
        return LucideIcons.moon;
      default:
        return LucideIcons.sun;
    }
  }
}
