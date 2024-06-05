import 'dart:io';

import 'package:fl_lib/src/core/utils/platform/base.dart';

/// Archs that Flutter can runs on.
enum CpuArch {
  amd64,
  arm64,
  arm,
  ;

  static const amd64Codes = ['x86_64', 'amd64'];
  static const arm64Codes = [
    'arm64',
    'aarch64',
    'armv8',
    'armv8a',
    'arm64-v8a',
    'arm64e'
  ];
  static const armCodes = [
    'arm',
    'armv7',
    'armv7a',
    'armv7l',
    'armv6',
    'armv6l',
    'armeabi',
    'armeabi-v7a',
    'armv5',
    'armv5te'
  ];

  static CpuArch get current {
    switch (Pfs.type) {
      case Pfs.windows:
        final cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
        return switch (cpu) {
          'AMD64' => CpuArch.amd64,
          'ARM64' => CpuArch.arm64,
          _ => throw UnsupportedError('Unsupported CPU architecture: $cpu'),
        };
      case Pfs.ios:
        return CpuArch.arm64;
      case Pfs.linux || Pfs.android || Pfs.macos || Pfs.fuchsia:
        final cpu = Process.runSync('uname', ['-m']);
        if (cpu.exitCode != 0) {
          throw Exception('Failed to run uname -m: ${cpu.stderr}');
        }
        final output = cpu.stdout.toString().trim();
        if (amd64Codes.contains(output)) return CpuArch.amd64;
        if (arm64Codes.contains(output)) return CpuArch.arm64;
        if (armCodes.contains(output)) return CpuArch.arm;
        throw UnsupportedError('Unsupported CPU architecture: $output');
      case Pfs.web || Pfs.unknown:
        throw UnsupportedError('Unsupported platform: ${Pfs.type}');
    }
  }
}
