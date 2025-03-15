import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'user.dart';
part 'file.dart';
part 'sse.dart';

/// API URLs
abstract final class ApiUrls {
  static const base = 'https://api.lpkt.cn';
  static const oauth = '$base/auth/oauth';
  static const user = '$base/auth/user';
  static const file = '$base/file';
  static const sse = '$base/sse';
}
