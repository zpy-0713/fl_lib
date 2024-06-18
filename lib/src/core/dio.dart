import 'package:dio/dio.dart';

final myDio = Dio(BaseOptions(
  headers: {'lk-app-client': '1'},
  validateStatus: (_) => true,
));
