import 'dart:io';

import 'package:fl_lib/src/core/utils/platform/base.dart';

/// Archs that Flutter can runs on.
enum CpuArch {
  x64,
  arm64,
  arm,
  ;

  static CpuArch get current {
    switch (Pfs.type) {
      case Pfs.windows:
        final cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
        return switch (cpu) {
          'AMD64' => CpuArch.x64,
          'ARM64' => CpuArch.arm64,
          _ => throw UnsupportedError('Unsupported CPU architecture: $cpu'),
        };
      case Pfs.linux || Pfs.android || Pfs.macos || Pfs.fuchsia || Pfs.ios:
        final cpu = Process.runSync('uname', ['-m']);
        if (cpu.exitCode != 0) {
          throw Exception('Failed to run uname -m: ${cpu.stderr}');
        }
        final output = cpu.stdout.toString().trim();
        return switch (output) {
          'x86_64' => CpuArch.x64,
          'arm64' => CpuArch.arm64,
          'armv7l' => CpuArch.arm,
          _ => throw UnsupportedError('Unsupported CPU architecture: $output'),
        };
      case Pfs.web || Pfs.unknown:
        throw UnsupportedError('Unsupported platform: ${Pfs.type}');
    }
  }
}
