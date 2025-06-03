// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fl_lib/fl_lib.dart';
import 'package:logging/logging.dart';

abstract final class Loggers {
  static final root = Logger('Root');
  static final store = Logger('Store');
  static final route = Logger('Route');
  static final app = Logger('App');

  /// Regex to extract source file and line number from a stack trace.
  static final sourceReg = RegExp(r'\((.+):(\d+):(\d+)\)');

  /// Logs a message with the source file and line number.
  static void log(Object message, {int skipFrames = 1}) {
    final traceLines = StackTrace.current.toString().split('\n');

    if (traceLines.length > skipFrames) {
      final caller = traceLines[skipFrames];
      final match = sourceReg.firstMatch(caller);
      if (match != null) {
        String? file = match.group(1)?.replaceFirst('file://', '');
        final line = match.group(2);
        if (file != null) {
          final pwd = Directory.current.path;
          if (file.startsWith(pwd)) {
            file = file.substring(pwd.length + 1); // +1 to remove the leading '/'
            file = './$file'; // Make it relative
          }
        }
        print('[$file:$line] $message');
        return;
      }
    }
    print(message);
  }
}

/// Print [msg]s only in debug mode.
void dprint(Object? msg, [Object? msg2, Object? msg3, Object? msg4]) {
  if (!BuildMode.isDebug) return;
  lprint(msg, msg2, msg3, msg4, 3);
}

/// Print [msg]s to console and debug provider.
/// 
/// With [Loggers.log], it will also print the source file and line number.
void lprint(Object? msg, [Object? msg2, Object? msg3, Object? msg4, int skipFrames = 2]) {
  final sb = StringBuffer();
  sb.write(msg.toString()); // Always print the first message

  if (msg2 != null) {
    sb.write('\t$msg2');
  }
  if (msg3 != null) {
    sb.write('\t$msg3');
  }
  if (msg4 != null) {
    sb.write('\t$msg4');
  }
  final str = sb.toString();
  Loggers.log(str, skipFrames: skipFrames);
  DebugProvider.addString(str);
}
