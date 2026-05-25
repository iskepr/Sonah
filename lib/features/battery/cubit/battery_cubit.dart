import "dart:async";
import "package:battery_plus/battery_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/extensions/extensions.dart";

@immutable
abstract class BatteryCubitState {}

class BatteryInitial extends BatteryCubitState {}

class BatteryLoaded extends BatteryCubitState {
  final BatteryState batteryState;
  final int batteryLevel;
  BatteryLoaded({required this.batteryLevel, required this.batteryState});
}

class BatteryCubit extends Cubit<BatteryCubitState> {
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _subscription;
  Timer? _timer;

  BatteryCubit() : super(BatteryInitial()) {
    _initBattery();
  }

  void _initBattery() async {
    await _updateBatteryInfo();

    _subscription = _battery.onBatteryStateChanged.listen(
      (_) async => await _updateBatteryInfo(),
    );

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) async => await _updateBatteryInfo(),
    );
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
    _timer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
