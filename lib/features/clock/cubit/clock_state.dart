class ClockState {}

class ClockInitial extends ClockState {}

class ClockLoaded extends ClockState {
  final String clock;
  ClockLoaded(this.clock);
}
