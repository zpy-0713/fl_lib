/// See: https://github.com/flutter/flutter/issues/11392
enum BuildMode {
  release,
  debug,
  profile,
  ;

  static final isDebug = _buildMode == BuildMode.debug;
  static final isProfile = _buildMode == BuildMode.profile;
  static final isRelease = _buildMode == BuildMode.release;
}

final _buildMode = () {
  if (const bool.fromEnvironment('dart.vm.product')) {
    return BuildMode.release;
  }
  var result = BuildMode.profile;
  assert(() {
    result = BuildMode.debug;
    return true;
  }());
  return result;
}();

/// TODO: switch to macro in the future.
/// Print [msg] only in debug mode.
/// [msg] will convert to string by default.
void dprint(Object? msg) {
  if (BuildMode.isDebug) {
    // ignore: avoid_print
    print(msg);
  }
}
