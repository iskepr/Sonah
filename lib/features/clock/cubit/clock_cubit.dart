import "dart:async";
import "dart:ui";
import "package:flutter_bloc/flutter_bloc.dart";
import "clock_state.dart";
export "clock_state.dart";

class ClockCubit extends Cubit<ClockState> {
  ClockCubit() : super(ClockLoaded(_getCurrentTime()));

  Timer? _timer;
  static const bool withSeconds = false;

  static String _getCurrentTime() {
    final now = DateTime.now();
    final bool is24Hour = PlatformDispatcher.instance.alwaysUse24HourFormat;

    if (is24Hour) {
      return "${_format(now.hour)}:${_format(now.minute)}${withSeconds ? ":${_format(now.second)}" : ""}";
    } else {
      int hour = now.hour % 12;
      hour = hour == 0 ? 12 : hour;
      final String period = now.hour >= 12 ? "PM" : "AM";
      return "${_format(hour)}:${_format(now.minute)}${withSeconds ? ":${_format(now.second)}" : ""}$period";
    }
  }

  static String _format(int value) => value.toString().padLeft(2, "0");

  void load() => _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    emit(ClockLoaded(_getCurrentTime()));
  });

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
