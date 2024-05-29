import 'package:dio/dio.dart';

final myDio = Dio(BaseOptions(
  headers: {'x-lk-client': '1'},
));
