import 'package:fl_lib/fl_lib.dart';

final class InternalStore extends PersistentStore {
  InternalStore._() : super('internal');

  static final instance = InternalStore._();

  late final pbAuth = property('pb_auth', '');
}
