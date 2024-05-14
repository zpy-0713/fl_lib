extension DurationX on Duration {
  String toAgoStr({
    String? day,
    String? hour,
    String? minute,
    String? second,
  }) {
    final days = inDays;
    if (days > 0) {
      return '$days ${day ?? 'd'}';
    }
    final hours = inHours % 24;
    if (hours > 0) {
      return '$hours ${hour ?? 'h'}';
    }
    final minutes = inMinutes % 60;
    if (minutes > 0) {
      return '$minutes ${minute ?? 'm'}';
    }
    final seconds = inSeconds % 60;
    return '$seconds ${second ?? 's'}';
  }
}
