import 'dart:async';
import 'dart:collection';

class AsyncQueue<T> {
  final bool collectRet;

  AsyncQueue({
    this.collectRet = false,
  }) : returns = collectRet ? StreamController<T>() : null;

  final _queue = Queue<FutureOr<T>>();
  final StreamController<T>? returns;

  /// Since Dart is single-threaded, Mutex is not needed.
  bool _isProcessing = false;

  void addTask(FutureOr<T> task) {
    _queue.add(task);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      returns?.add(await _queue.removeFirst());
    }

    _isProcessing = false;
  }
}
