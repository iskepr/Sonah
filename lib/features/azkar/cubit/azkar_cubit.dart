import "dart:async";

import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
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
        final now = DateTimeHelper.now;

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

    // أذكار بعد الصلاة
    if (athanState.activePrayer != Prayer.none) {
      targetAzkar = AzkarConstants.getPrayerAzkar(_lastActivePrayer);
    }
    // أذكار اليوم
    else {
      targetAzkar = kAzkarTyps
          .firstWhereOrNull(
            (azkar) => azkar.azkarByType.isInRange(now, prayerTimes),
          )
          ?.azkarByType;
    }

    if (targetAzkar == null) {
      if (state is! AzkarInitial) safeEmit(AzkarInitial());
      return;
    }

    if (state is AzkarLoaded &&
        (state as AzkarLoaded).azkar.type == targetAzkar.type) {
      return;
    }

    safeEmit(AzkarLoading());
    _initializeAzkar(targetAzkar);
  }

  void _initializeAzkar(Azkar azkar) {
    final list = azkar.data;
    final Map<int, int> counts = {};
    for (int i = 0; i < list.length; i++) {
      counts[i] = list[i].count;
    }
    safeEmit(AzkarLoaded(azkar: azkar, currentCounts: counts));
  }

  void decrementCounter(int index, VoidCallback onPageNext) {
    if (state is! AzkarLoaded) return;

    final currentState = state as AzkarLoaded;
    final Map<int, int> updatedCounts = Map.from(currentState.currentCounts);

    if (updatedCounts[index]! > 1) {
      updatedCounts[index] = updatedCounts[index]! - 1;
      safeEmit(
        AzkarLoaded(azkar: currentState.azkar, currentCounts: updatedCounts),
      );
      VibrationService.light();
    } else {
      VibrationService.strong();
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

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
