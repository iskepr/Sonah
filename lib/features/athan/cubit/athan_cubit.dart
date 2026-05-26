import "dart:async";
import "package:adhan/adhan.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/service/ticker_service.dart";
import "../../../core/utils/get_location.dart";
import "../../../core/utils/show_message.dart";
import "../extensions/athan_extenstion.dart";

class AthanState {}

class AthanInitial extends AthanState {}

class AthanLoading extends AthanState {}

class AthanLoaded extends AthanState {
  final PrayerTimes prayerTimes;
  final String nextPrayerName;
  final String remainingTime;

  AthanLoaded({
    required this.prayerTimes,
    required this.nextPrayerName,
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

    WidgetsBinding.instance.addPostFrameCallback((_) => getAthanTimes());
  }

  void getAthanTimes() async {
    if (isClosed) return;
    try {
      safeEmit(AthanLoading());
      final location = await getCurrentLocation();
      if (location == null || isClosed) return;

      _coordinates = Coordinates(location.latitude, location.longitude);
      _params = CalculationMethod.karachi.getParameters();
      _params!.madhab = Madhab.hanafi;

      _todayPrayers = PrayerTimes.today(_coordinates!, _params!);

      _updateTick(DateTime.now());
    } catch (e) {
      if (!isClosed) showMessage(e.toString(), isError: true);
    }
  }

  void _startCentralTimer() {
    _subscription = tickerService.timeStream.listen((now) {
      _updateTick(now);
    });
  }

  void _updateTick(DateTime now) {
    if (_todayPrayers == null ||
        _coordinates == null ||
        _params == null ||
        isClosed) {
      return;
    }

    Prayer next = _todayPrayers!.nextPrayer();
    DateTime? targetTime = _todayPrayers!.timeForPrayer(next);

    if (next == Prayer.none ||
        (next == Prayer.isha && now.isAfter(_todayPrayers!.isha))) {
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
        nextPrayerName: next.prayerName,
        remainingTime: countdownStr,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
