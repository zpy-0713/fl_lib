import 'package:fl_lib/src/res/l10n.dart';

extension DurationX on Duration {
  String get toAgoStr {
    final days = inDays;
    if (days > 0) {
      return '$days ${l10n.day}';
    }
    final hours = inHours % 24;
    if (hours > 0) {
      return '$hours ${l10n.hour}';
    }
    final minutes = inMinutes % 60;
    if (minutes > 0) {
      return '$minutes ${l10n.minute}';
    }
    final seconds = inSeconds % 60;
    return '$seconds ${l10n.second}';
  }
}
