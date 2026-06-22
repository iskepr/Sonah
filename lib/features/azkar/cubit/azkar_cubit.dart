import "dart:async";

import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/helpers/hive_helper.dart";
import "../../../core/service/vibration_service.dart";
import "../../athan/cubit/athan_cubit.dart";
import "../data/azkar_data.dart";
import "azkar_state.dart";

export "azkar_state.dart";

class AzkarCubit extends Cubit<AzkarState> {
  final AthanCubit athanCubit;
  StreamSubscription? _athanSubscription;

  AzkarCubit({required this.athanCubit}) : super(AzkarInitial()) {
    _athanSubscription = athanCubit.stream.listen((athanState) {
      if (athanState is AthanLoaded) determineAzkar(athanState);
    });
  }

  void determineAzkar(AthanLoaded athanState) {
    final now = DateTime.now();
    final prayerTimes = athanState.prayerTimes;

    debugPrint(
      "Current time: $now, Fajr time: ${prayerTimes.fajr}, Active prayer: ${athanState.activePrayer}",
    );

    List<dynamic>? targetAzkar;
    String targetTitle = "";

    // أذكار الاستيقاظ
    final DateTime wakeUpTime =
        HiveHelper.getDataByKey(kBoxSettings, "wakeUpTime") ?? prayerTimes.fajr;

    if (now.difference(wakeUpTime).inMinutes.abs() <= 30) {
      targetAzkar = AzkarConstants.wakingUp;
      targetTitle = l10n.azkarAfterWakeUp;
    }
    // أذكار بعد الصلاة
    else if (athanState.activePrayer != Prayer.none) {
      final filteredAzker = AzkarConstants.afterPrayer
          .where(
            (z) =>
                z.prayers == null ||
                z.prayers!.isEmpty ||
                z.prayers!.contains(athanState.activePrayer),
          )
          .toList();

      if (filteredAzker.isNotEmpty) {
        targetAzkar = filteredAzker;
        targetTitle = l10n.azkarAfterPrayer;
      }
    }
    // أذكار الصباح - من الفجر الى الظهر
    else if (now.isAfter(prayerTimes.fajr) &&
        now.isBefore(prayerTimes.dhuhr.add(const Duration(hours: 1)))) {
      targetAzkar = AzkarConstants.morning;
      targetTitle = l10n.azkarMorning;
    }
    // أذكار المساء - من العصر الى المغرب
    else if (now.isAfter(prayerTimes.asr) &&
        now.isBefore(prayerTimes.maghrib)) {
      targetAzkar = AzkarConstants.evening;
      targetTitle = l10n.azkarEvening;
    }

    // أذكار النوم - من العشاء الى الفجر
    final int nowMinutes = now.hour * 60 + now.minute;
    final int ishaMinutes =
        prayerTimes.isha.hour * 60 + prayerTimes.isha.minute;
    final int fajrMinutes =
        prayerTimes.fajr.hour * 60 + prayerTimes.fajr.minute;

    if (nowMinutes >= ishaMinutes || nowMinutes < fajrMinutes) {
      targetAzkar = AzkarConstants.beforeSleep;
      targetTitle = l10n.azkarBeforeSleep;
    }

    if (targetAzkar == null || targetTitle.isEmpty) {
      if (state is! AzkarInitial) safeEmit(AzkarInitial());
      return;
    }
    if (state is AzkarLoaded && (state as AzkarLoaded).title == targetTitle) {
      return;
    }

    safeEmit(AzkarLoading());
    _initializeAzkar(targetAzkar, targetTitle);
  }

  void _initializeAzkar(List<dynamic> list, String title) {
    final Map<int, int> counts = {};
    for (int i = 0; i < list.length; i++) {
      counts[i] = list[i].count;
    }
    safeEmit(AzkarLoaded(azkarList: list, currentCounts: counts, title: title));
  }

  void decrementCounter(int index, VoidCallback onPageNext) {
    if (state is! AzkarLoaded) return;
    VibrationService.light();

    final currentState = state as AzkarLoaded;
    final Map<int, int> updatedCounts = Map.from(currentState.currentCounts);

    if (updatedCounts[index]! > 1) {
      updatedCounts[index] = updatedCounts[index]! - 1;
      safeEmit(
        AzkarLoaded(
          azkarList: currentState.azkarList,
          currentCounts: updatedCounts,
          title: currentState.title,
        ),
      );
    } else {
      if (index < currentState.azkarList.length - 1) {
        onPageNext();
      } else {
        safeEmit(AzkarFinished());
      }
    }
  }

  @override
  Future<void> close() async {
    await _athanSubscription?.cancel();
    return super.close();
  }
}
