import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

final class Turnstile extends CloudflareTurnstile {
  static const mySiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');
  static const verifyEndpoint = 'https://api.lpkt.cn/auth/turnstile';

  Turnstile({
    super.siteKey = mySiteKey,
    super.key,
    super.onError,
    required super.onTokenReceived,
    super.baseUrl = 'https://api.lpkt.cn',
    super.onTokenExpired,
    super.action,
    super.cData,
    super.controller,
    super.options,
  });
}
