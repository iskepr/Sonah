import "package:adhan/adhan.dart";

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
}
