import "dart:async";

class TickerService {
  StreamController<DateTime>? _controller;
  Timer? _timer;

  Stream<DateTime> get timeStream {
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<DateTime>.broadcast(
        onListen: _startTimer,
        onCancel: _stopTimer,
      );
    }
    return _controller!.stream;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_controller != null &&
          !_controller!.isClosed &&
          _controller!.hasListener) {
        _controller!.add(DateTime.now());
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void pause() => _stopTimer();
  void resume() => _startTimer();

  void dispose() {
    _stopTimer();
    _controller?.close();
  }
}
