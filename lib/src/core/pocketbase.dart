import 'package:fl_lib/fl_lib.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase(
  'https://pb.lpkt.cn',
  authStore: AsyncAuthStore(
    save: (s) => PrefStore.set(Pbs.pbAuthKey, s),
    clear: () => PrefStore.remove(Pbs.pbAuthKey),
    initial: PrefStore.get<String>(Pbs.pbAuthKey),
  ),
);

abstract class Pbs {
  static const pbAuthKey = 'pb_auth';
}
