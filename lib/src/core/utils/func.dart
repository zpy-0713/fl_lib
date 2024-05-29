abstract final class Funcs {
  static const int _defaultDurationTime = 377;
  static const String _defaultThrottleId = 'default';
  static final Map<String, int> startTimeMap = <String, int>{
    _defaultThrottleId: 0
  };

  static T? throttle<T>(
    T Function() func, {
    String id = _defaultThrottleId,
    int duration = _defaultDurationTime,
    Function? continueClick,
  }) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - (startTimeMap[id] ?? 0) > duration) {
      final ret = func();
      startTimeMap[id] = DateTime.now().millisecondsSinceEpoch;
      return ret;
    } else {
      continueClick?.call();
      return null;
    }
  }
}
