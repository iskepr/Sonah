import "dart:async";

class TickerService {
  StreamController<DateTime>? _controller;
  Timer? _timer;

  Stream<DateTime> get timeStream {
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<DateTime>.broadcast();
      _startTimer();
    }
    return _controller!.stream;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_controller != null && !_controller!.isClosed) {
        _controller!.add(DateTime.now());
      }
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    _startTimer();
  }

  void dispose() {
    _timer?.cancel();
    _controller?.close();
  }
}
