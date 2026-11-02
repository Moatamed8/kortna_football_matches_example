import "dart:async";

abstract class Ticker {
  void schedule(Duration delay, void Function() callback);
  void cancel();
}

class TimerTicker implements Ticker {
  Timer? _timer;

  @override
  void schedule(Duration delay, void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
