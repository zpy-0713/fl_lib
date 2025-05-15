abstract final class SnowflakeLite {
  static int _lastMs = 0; // 41 bit timestamp
  static int _seq = 0; // 12 bit No.

  /// Generates a unique ID using a simple snowflake algorithm.
  static String generate() {
    var now = DateTime.now().millisecondsSinceEpoch;

    if (now == _lastMs) {
      _seq = (_seq + 1) & 0xFFF; // 0-4095
      if (_seq == 0) {
        // Wait for the next millisecond
        while ((now = DateTime.now().millisecondsSinceEpoch) == _lastMs) {}
      }
    } else {
      _seq = 0;
      _lastMs = now;
    }

    // 41 bit ts + 12 bit No. = 53 bit
    // It's safe to save as 64 bit int
    final id = (now << 12) | _seq;
    return id.toRadixString(36);
  }

  /// Decodes a SnowflakeLite ID back to its timestamp and sequence number.
  static (DateTime, int) decode(String id) {
    final intId = int.parse(id, radix: 36);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(intId >> 12);
    final sequence = intId & 0xFFF;
    return (timestamp, sequence);
  }
}
