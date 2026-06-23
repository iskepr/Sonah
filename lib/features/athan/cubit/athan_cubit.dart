import "dart:async";
import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/service/ticker_service.dart";
import "../../../core/utils/get_location.dart";
import "../../../core/utils/show_message.dart";

class AthanState {}

class AthanInitial extends AthanState {}

class AthanLoading extends AthanState {}

class AthanLoaded extends AthanState {
  final PrayerTimes prayerTimes;
  final Prayer activePrayer;
  final Prayer nextPrayer;
  final String remainingTime;

  AthanLoaded({
    required this.prayerTimes,
    required this.activePrayer,
    required this.nextPrayer,
    required this.remainingTime,
  });
}

class AthanCubit extends Cubit<AthanState> {
  final TickerService tickerService;
  StreamSubscription? _subscription;

  PrayerTimes? _todayPrayers;
  Coordinates? _coordinates;
  CalculationParameters? _params;

  AthanCubit({required this.tickerService}) : super(AthanInitial()) {
    _startCentralTimer();
    getLocalLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAthanTimes());
  }

  void getAthanTimes() async {
    if (isClosed) return;
    try {
      safeEmit(AthanLoading());

      final cachedLocation = await getLocalLocation();
      if (cachedLocation == null) return;
      _coordinates = Coordinates(
        cachedLocation["latitude"],
        cachedLocation["longitude"],
      );

      _params = CalculationMethod.egyptian.getParameters();

      _todayPrayers = PrayerTimes.today(_coordinates!, _params!);

      _updateTick(DateTimeHelper.now);
    } catch (e) {
      if (!isClosed) showMessage(e.toString(), isError: true);
    }
  }

  void _startCentralTimer() => _subscription = tickerService.timeStream.listen(
    (now) => _updateTick(now),
  );

  void _updateTick(DateTime now) {
    if (_todayPrayers == null ||
        _coordinates == null ||
        _params == null ||
        isClosed) {
      return;
    }

    final Prayer activePrayer = _getCurrentPrayer(_todayPrayers!, now);
    Prayer next = _todayPrayers!.nextPrayer();
    DateTime? targetTime = _todayPrayers!.timeForPrayer(next);

    if (next == Prayer.none) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayers = PrayerTimes(
        _coordinates!,
        DateComponents.from(tomorrow),
        _params!,
      );
      next = Prayer.fajr;
      targetTime = tomorrowPrayers.fajr;
    }

    final countdownStr =
        targetTime?.differenceToFormattedString(now) ?? "00:00:00";

    safeEmit(
      AthanLoaded(
        prayerTimes: _todayPrayers!,
        activePrayer: activePrayer,
        nextPrayer: next,
        remainingTime: countdownStr,
      ),
    );
  }

  Prayer _getCurrentPrayer(PrayerTimes prayerTimes, DateTime now) {
    final Map<Prayer, DateTime> prayerMap = {
      Prayer.fajr: prayerTimes.fajr,
      Prayer.dhuhr: prayerTimes.dhuhr,
      Prayer.asr: prayerTimes.asr,
      Prayer.maghrib: prayerTimes.maghrib,
      Prayer.isha: prayerTimes.isha,
    };

    for (var entry in prayerMap.entries) {
      final difference = now.difference(entry.value).inMinutes;
      if (difference >= 0 && difference <= 35) {
        return entry.key;
      }
    }

    return Prayer.none;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
