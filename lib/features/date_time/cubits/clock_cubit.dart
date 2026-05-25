import "dart:async";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/service/ticker_service.dart";

class ClockState {}

class ClockInitial extends ClockState {}

class ClockLoaded extends ClockState {
  final String clock;
  ClockLoaded(this.clock);
}

class ClockCubit extends Cubit<ClockState> {
  final TickerService tickerService;
  StreamSubscription? _subscription;
  int? _lastMinute;

  static String get nowString => DateTime.now().toTimeOnly(showPeriod: false);

  ClockCubit({required this.tickerService}) : super(ClockLoaded(nowString)) {
    _subscription = tickerService.timeStream.listen((now) {
      if (_lastMinute == null || _lastMinute != now.minute) {
        _lastMinute = now.minute;
        emit(ClockLoaded(nowString));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
