import "dart:async";

class TickerService {
  Stream<DateTime> get timeStream {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }
}
