import "dart:async"; // ضفنا دي عشان الـ StreamSubscription
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
      if (athanState is AthanLoaded) determineAzkar();
    });
  }

  void determineAzkar() {
    safeEmit(AzkarLoading());

    final athanState = athanCubit.state;
    final now = DateTime.now();

    // 1. فحص أذكار بعد الصلاة
    if (athanState is AthanLoaded) {
      final times = athanState.prayerTimes;
      final prayers = [
        times.fajr,
        times.dhuhr,
        times.asr,
        times.maghrib,
        times.isha,
      ];

      final bool isAfterPrayer = prayers.any((prayerTime) {
        final difference = now.difference(prayerTime).inMinutes;
        return difference >= 0 && difference <= 20;
      });

      if (isAfterPrayer) {
        _initializeAzkar(AzkarConstants.afterPrayer, l10n.azkarAfterPrayer);
        return;
      }
    }

    final DateTime wakeUpTime =
        HiveHelper.getTDataByKey(kBoxSettings, "wakeUpTime") ??
        DateTime(now.year, now.month, now.day, 7, 0);
    final DateTime sleepTime =
        HiveHelper.getTDataByKey(kBoxSettings, "sleepTime") ??
        DateTime(now.year, now.month, now.day, 23, 0);

    if (now.difference(wakeUpTime).inMinutes.abs() <= 30) {
      _initializeAzkar(AzkarConstants.wakingUp, l10n.azkarAfterWake);
      return;
    }

    if (now.isAfter(sleepTime.subtract(const Duration(minutes: 30))) &&
        now.isBefore(sleepTime.add(const Duration(hours: 1)))) {
      _initializeAzkar(AzkarConstants.beforeSleep, l10n.azkarBeforeSleep);
      return;
    }

    if (athanState is AthanLoaded) {
      final times = athanState.prayerTimes;
      if (now.isAfter(times.fajr) &&
          now.isBefore(times.dhuhr.add(const Duration(hours: 1)))) {
        _initializeAzkar(AzkarConstants.morning, l10n.azkarMorning);
        return;
      } else if (now.isAfter(times.asr) && now.isBefore(times.maghrib)) {
        _initializeAzkar(AzkarConstants.evening, l10n.azkarEvening);
        return;
      }
    } else {
      debugPrint("athanState is not AthanLoaded yet...");
      safeEmit(AzkarLoaded(azkarList: [], currentCounts: {}, title: ""));
    }
  }

  void _initializeAzkar(List<dynamic> list, String title) {
    final Map<int, int> counts = {};
    for (int i = 0; i < list.length; i++) {
      counts[i] = list[i].count;
    }
    safeEmit(AzkarLoaded(azkarList: list, currentCounts: counts, title: title));
  }

  void decrementCounter(int index, Function() onPageNext) {
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
  Future<void> close() {
    _athanSubscription?.cancel();
    return super.close();
  }
}
