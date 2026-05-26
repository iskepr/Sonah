import "dart:async";
import "package:battery_plus/battery_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/service/ticker_service.dart";

@immutable
abstract class BatteryCubitState {}

class BatteryInitial extends BatteryCubitState {}

class BatteryLoaded extends BatteryCubitState {
  final BatteryState batteryState;
  final int batteryLevel;
  BatteryLoaded({required this.batteryLevel, required this.batteryState});
}

class BatteryCubit extends Cubit<BatteryCubitState> {
  final TickerService tickerService;
  final Battery _battery = Battery();

  StreamSubscription? _tickerSubscription;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  BatteryCubit({required this.tickerService}) : super(BatteryInitial()) {
    startListening();
  }

  void startListening() async {
    stopListening();

    await _updateBatteryInfo();

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
      (_) async => await _updateBatteryInfo(),
    );

    _tickerSubscription = tickerService.timeStream.listen((now) async {
      if (now.second == 0) await _updateBatteryInfo();
    });
  }

  void stopListening() {
    _tickerSubscription?.cancel();
    _batteryStateSubscription?.cancel();
    _tickerSubscription = null;
    _batteryStateSubscription = null;
  }

  Future<void> _updateBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;

      safeEmit(BatteryLoaded(batteryLevel: level, batteryState: state));
    } catch (e) {
      debugPrint("Error updating battery: $e");
    }
  }

  @override
  Future<void> close() {
    stopListening();
    return super.close();
  }
}
