import 'package:fl_lib/src/res/l10n.dart';

extension DurationX on Duration {
  String get toAgoStr {
    final abs_ = abs();
    final days = abs_.inDays;
    if (days > 0) {
      return '$days ${l10n.day}';
    }
    final hours = abs_.inHours;
    if (hours > 0) {
      return '$hours ${l10n.hour}';
    }
    final minutes = abs_.inMinutes;
    if (minutes > 0) {
      return '$minutes ${l10n.minute}';
    }
    final seconds = abs_.inSeconds;
    return '$seconds ${l10n.second}';
  }
}
