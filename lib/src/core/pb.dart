import 'package:fl_lib/src/res/stores.dart';
import 'package:pocketbase/pocketbase.dart';

PocketBase? _pb;
PocketBase get pb => _pb!;

abstract final class Pbs {
  static void init(String url) {
    _pb = PocketBase(
      url,
      authStore: AsyncAuthStore(
        save: (String data) async => InternalStore.instance.pbAuth.put(data),
        initial: InternalStore.instance.pbAuth.fetch(),
      ),
    );
  }

  static String? get uid => pb.authStore.model?.id;
}
