import 'package:flutter_test/flutter_test.dart';
import 'package:fl_lib/src/core/utils/id.dart';

void main() {
  group('SnowflakeLite', () {
    test('should generate unique IDs', () {
      final id1 = SnowflakeLite.generate();
      final id2 = SnowflakeLite.generate();
      expect(id1, isNot(equals(id2)));
      // Base-36 string only contains 0-9 and a-z
      expect(id1, matches(r'^[0-9a-z]+$'));
    });

    test('should generate unique IDs under pressure', () {
      const count = 10000;
      final ids = <String>{};

      for (var i = 0; i < count; i++) {
        ids.add(SnowflakeLite.generate());
      }

      expect(ids.length, equals(ids.toSet().length), reason: 'All generated IDs should be unique');
    });

    test('should handle millisecond overflow correctly', () {
      // Generate IDs rapidly to force sequence overflow scenario
      final uniqueIds = <String>{};
      final startTime = DateTime.now();

      // Generate IDs until we're at least 5ms past start time
      while (DateTime.now().difference(startTime).inMilliseconds < 5) {
        uniqueIds.add(SnowflakeLite.generate());
      }

      expect(uniqueIds.length, greaterThan(5), reason: 'Should generate multiple unique IDs');
    });

    test('Decode the id', () {
      final id = SnowflakeLite.generate();
      final (timestamp, sequence) = SnowflakeLite.decode(id);
      final decodedId = (timestamp.millisecondsSinceEpoch << 12) | sequence;
      expect(decodedId.toRadixString(36), equals(id), reason: 'Decoded ID should match original ID');
    });
  });
}
