import 'package:fl_lib/src/core/ext/datetime.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_lib/src/core/store/iface.dart';
import 'package:fl_lib/src/core/sync/base.dart';

void main() {
  group('Mergeable.mergeStore', () {
    late MockStore store;

    setUp(() {
      // Initialize a fresh MockStore before each test
      store = MockStore();
    });

    test('adds new keys from backup', () async {
      // Prepare backup data with timestamp
      final backupData = {
        'newKey1': 'value1',
        'newKey2': 42,
        store.lastUpdateTsKey: {
          'newKey1': 1000,
          'newKey2': 1001,
        }
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      // Verify new keys were added
      expect(store.get('newKey1'), 'value1');
      expect(store.get('newKey2'), 42);
      
      // Verify timestamps were updated
      final timestamps = store.lastUpdateTs;
      expect(timestamps?['newKey1'], greaterThan(1000));
      expect(timestamps?['newKey2'], greaterThan(1001));
    });

    test('does not delete keys when force is false', () async {
      // Set up existing data
      store.set('existingKey', 'existingValue');
      final initialMap = store.lastUpdateTs ?? <String, int>{};
      initialMap['existingKey'] = 500;
      store.set(store.lastUpdateTsKey, initialMap);
      
      // Backup data without the existing key
      final backupData = {
        'newKey': 'newValue',
        store.lastUpdateTsKey: {
          'newKey': 1000,
        }
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      // Verify existing key still exists
      expect(store.get('existingKey'), 'existingValue');
      expect(store.get('newKey'), 'newValue');
    });

    test('deletes keys when force is true', () async {
      // Set up existing data
      store.set('existingKey', 'existingValue');
      final initialMap = store.lastUpdateTs ?? <String, int>{};
      initialMap['existingKey'] = 500;
      store.set(store.lastUpdateTsKey, initialMap);
      
      // Backup data without the existing key
      final backupData = {
        'newKey': 'newValue',
        store.lastUpdateTsKey: {
          'newKey': 1000,
        }
      };

      // Perform merge with force=true
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: true,
      );

      // Verify existing key was deleted
      expect(store.get('existingKey'), null);
      expect(store.get('newKey'), 'newValue');
    });

    test('updates keys when backup timestamp is newer', () async {
      // Set up existing data with older timestamp
      store.set('commonKey', 'oldValue');
      expect(store.get('commonKey'), 'oldValue');
      
      // Backup data with newer timestamp
      final backupData = {
        'commonKey': 'newValue',
        store.lastUpdateTsKey: {
          'commonKey': DateTimeX.timestamp + 10, // newer timestamp
        }
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      // Verify value was updated
      expect(store.get('commonKey'), 'newValue');
    });

    test('does not update keys when current timestamp is newer', () async {
      // Set up existing data with newer timestamp
      store.set('commonKey', 'currentValue');
      final initialMap = store.lastUpdateTs ?? <String, int>{};
      initialMap['commonKey'] = 1500; // newer than backup
      store.set(store.lastUpdateTsKey, initialMap);
      
      // Backup data with older timestamp
      final backupData = {
        'commonKey': 'oldValue',
        store.lastUpdateTsKey: {
          'commonKey': 1000, // older timestamp
        }
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      // Verify value was not updated
      expect(store.get('commonKey'), 'currentValue');
    });

    test('forces update regardless of timestamp when force is true', () async {
      // Set up existing data with newer timestamp
      store.set('commonKey', 'currentValue');
      final initialMap = store.lastUpdateTs ?? <String, int>{};
      initialMap['commonKey'] = 1500; // newer than backup
      store.set(store.lastUpdateTsKey, initialMap);
      
      // Backup data with older timestamp
      final backupData = {
        'commonKey': 'oldValue',
        store.lastUpdateTsKey: {
          'commonKey': 1000, // older timestamp
        }
      };

      // Perform merge with force=true
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: true,
      );

      // Verify value was updated despite newer current timestamp
      expect(store.get('commonKey'), 'oldValue');
    });

    test('handles missing timestamp data gracefully', () async {
      // Backup data without timestamp information
      final backupData = {
        'newKey': 'newValue',
        // No timestamp map
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      expect(store.get('newKey'), 'newValue');
    });

    test('handles missing timestamp for specific key', () async {
      // Set up existing data
      store.set('commonKey', 'currentValue');
      final initialMap = store.lastUpdateTs ?? <String, int>{};
      initialMap['commonKey'] = 500;
      store.set(store.lastUpdateTsKey, initialMap);
      
      // Backup data with incomplete timestamp info
      final backupData = {
        'commonKey': 'newValue',
        'anotherKey': 'anotherValue',
        store.lastUpdateTsKey: {
          'anotherKey': 1000,
          // No timestamp for commonKey
        }
      };

      // Perform merge
      await Mergeable.mergeStore(
        backupData: backupData,
        store: store,
        force: false,
      );

      expect(store.get('commonKey'), 'currentValue');
      expect(store.get('anotherKey'), 'anotherValue');
    });
  });
}
