import 'dart:io';

class ProxyHttpOverrides extends HttpOverrides {
  final String? httpProxy;
  final String? httpsProxy;

  ProxyHttpOverrides(this.httpProxy, this.httpsProxy);

  static void useSystemProxy() async {
    final httpProxy = Platform.environment['HTTP_PROXY'] ?? Platform.environment['http_proxy'];
    final httpsProxy = Platform.environment['HTTPS_PROXY'] ?? Platform.environment['https_proxy'];

    if (httpProxy != null || httpsProxy != null) {
      HttpOverrides.global = ProxyHttpOverrides(httpProxy, httpsProxy);
    }
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) {
      if (uri.scheme == 'https' && httpsProxy != null) {
        return 'PROXY $httpsProxy';
      }
      if (httpProxy != null) {
        return 'PROXY $httpProxy';
      }
      return 'DIRECT';
    };
    return client;
  }
}
