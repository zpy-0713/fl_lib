extension DateTimeX on DateTime {
  String get hourMinute {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String ymd([String? separator]) {
    separator ??= '-';
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year$separator$month$separator$day';
  }

  String hms([String? separator]) {
    separator ??= ':';
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = this.second.toString().padLeft(2, '0');
    return '$hour$separator$minute$separator$second';
  }

  String ymdhms({String? ymdSep, String? hmsSep, String sep = ' '}) {
    return '${ymd(ymdSep)}$sep${hms(hmsSep)}';
  }

  static int get timestamp => DateTime.now().millisecondsSinceEpoch;
}
