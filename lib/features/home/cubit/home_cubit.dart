// home_cubit.dart
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../core/service/ticker_service.dart";
import "../../battery/cubit/battery_cubit.dart";

class HomeCubit extends Cubit<HomeState> {
  final TickerService _tickerService;
  final BatteryCubit _batteryCubit;

  HomeCubit({
    required TickerService tickerService,
    required BatteryCubit batteryCubit,
  }) : _tickerService = tickerService,
       _batteryCubit = batteryCubit,
       super(const HomeState());

  void handleScrollVelocity(double velocity) {
    if (velocity < -300 && !state.isSearchMode) {
      emit(state.copyWith(isSearchMode: true));
    } else if (velocity > 300 && state.isSearchMode) {
      emit(state.copyWith(isSearchMode: false));
    }
  }

  void closeSearch() {
    if (state.isSearchMode) {
      emit(state.copyWith(isSearchMode: false));
    }
  }

  void handleAppLifecycle(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused) {
      _tickerService.pause();
      _batteryCubit.stopListening();
      emit(state.copyWith(isAppPaused: true));
    } else if (lifecycleState == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _tickerService.resume();
      _batteryCubit.startListening();
      emit(state.copyWith(isAppPaused: false));
    }
  }

  @override
  Future<void> close() {
    _tickerService.dispose();
    _batteryCubit.close();
    return super.close();
  }
}

// home_state.dart
class HomeState {
  final bool isSearchMode;
  final bool isAppPaused;

  const HomeState({this.isSearchMode = false, this.isAppPaused = false});

  HomeState copyWith({bool? isSearchMode, bool? isAppPaused}) {
    return HomeState(
      isSearchMode: isSearchMode ?? this.isSearchMode,
      isAppPaused: isAppPaused ?? this.isAppPaused,
    );
  }
}
