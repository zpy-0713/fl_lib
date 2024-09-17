/// Build information.
///
/// To inject build info, use the following command during build:
/// ```bash
/// flutter build apk \
///   --dart-define=FL_LIB_APP_VER=1.0.0 \
///   --dart-define=FL_LIB_APP_NAME=MyApp
/// ```
abstract final class Build {
  /// eg.: `17`
  static const _ver = int.fromEnvironment('FL_LIB_APP_VER');
  static int? _mockVer;
  static int? get mockVer => BuildMode.isDebug ? _mockVer : null;
  static set mockVer(int? value) => _mockVer = value;
  static int get ver => mockVer ?? _ver;

  /// eg.: `GPTBox`
  static const _name = String.fromEnvironment('FL_LIB_APP_NAME');
  static String? _mockName;
  static String? get mockName => BuildMode.isDebug ? _mockName : null;
  static set mockName(String? value) => _mockName = value;
  static String get name => mockName ?? _name;

  /// eg.: `gptbox`
  static final _id = _name.toLowerCase().replaceAll(' ', '_');
  static String? _mockId;
  static String? get mockId => BuildMode.isDebug ? _mockId : null;
  static set mockId(String? value) => _mockId = value;
  static String get id => mockId ?? _id;
}

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
