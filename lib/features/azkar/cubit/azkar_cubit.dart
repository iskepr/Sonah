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

  Prayer? _lastActivePrayer;
  int? _lastMinute;

  AzkarCubit({required this.athanCubit}) : super(AzkarInitial()) {
    _athanSubscription = athanCubit.stream.listen((athanState) {
      if (athanState is AthanLoaded) {
        final now = DateTime.now();

        if (_lastActivePrayer == athanState.activePrayer &&
            _lastMinute == now.minute) {
          return;
        }

        _lastActivePrayer = athanState.activePrayer;
        _lastMinute = now.minute;

        determineAzkar(athanState, now);
      }
    });
  }

  void determineAzkar(AthanLoaded athanState, DateTime now) {
    final prayerTimes = athanState.prayerTimes;

    Azkar? targetAzkar;

    final int nowMinutes = now.hour * 60 + now.minute;
    final int ishaMinutes =
        prayerTimes.isha.hour * 60 + prayerTimes.isha.minute;
    final int fajrMinutes =
        prayerTimes.fajr.hour * 60 + prayerTimes.fajr.minute;

    // أذكار الاستيقاظ
    final DateTime wakeUpTime =
        HiveHelper.getDataByKey(kBoxSettings, "wakeUpTime") ?? prayerTimes.fajr;

    if (now.difference(wakeUpTime).inMinutes.abs() <= 30) {
      targetAzkar = AzkarConstants.wakingUp;
    }
    // أذكار بعد الصلاة
    else if (athanState.activePrayer != Prayer.none) {
      targetAzkar = AzkarConstants.afterPrayer;
    }
    // أذكار الصباح - من الفجر الى الظهر
    else if (now.isAfter(prayerTimes.fajr) &&
        now.isBefore(prayerTimes.dhuhr.add(const Duration(hours: 1)))) {
      targetAzkar = AzkarConstants.morning;
    }
    // أذكار المساء - من العصر الى المغرب
    else if (now.isAfter(prayerTimes.asr) &&
        now.isBefore(prayerTimes.maghrib)) {
      targetAzkar = AzkarConstants.evening;
    }
    // أذكار النوم - من العشاء الى الفجر
    else if (nowMinutes >= ishaMinutes || nowMinutes < fajrMinutes) {
      targetAzkar = AzkarConstants.sleep;
    }

    if (targetAzkar == null) {
      if (state is! AzkarInitial) safeEmit(AzkarInitial());
      return;
    }
    if (state is AzkarLoaded &&
        (state as AzkarLoaded).azkar.title == targetAzkar.title) {
      return;
    }

    safeEmit(AzkarLoading());
    _initializeAzkar(targetAzkar);
  }

  void _initializeAzkar(Azkar azkar) {
    final list = AzkarConstants.getPrayerAzkar(
      azkar.data,
      azkar.type == AzkarType.afterPrayer,
      prayer: _lastActivePrayer,
    );
    final Map<int, int> counts = {};
    for (int i = 0; i < list.length; i++) {
      counts[i] = list[i].count;
    }
    safeEmit(AzkarLoaded(azkar: azkar, currentCounts: counts));
  }

  void decrementCounter(int index, VoidCallback onPageNext) {
    if (state is! AzkarLoaded) return;
    VibrationService.light();

    final currentState = state as AzkarLoaded;
    final Map<int, int> updatedCounts = Map.from(currentState.currentCounts);

    if (updatedCounts[index]! > 1) {
      updatedCounts[index] = updatedCounts[index]! - 1;
      safeEmit(
        AzkarLoaded(azkar: currentState.azkar, currentCounts: updatedCounts),
      );
    } else {
      if (index < currentState.azkar.data.length - 1) {
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
