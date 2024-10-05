import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';

final class Turnstile extends StatelessWidget {
  static const siteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');
  static const verifyEndpoint = 'https://api.lpkt.cn/auth/turnstile';

  final void Function([String? err])? onError;
  final void Function(String) onToken;
  final String? baseUrl;

  const Turnstile({
    super.key,
    this.onError,
    required this.onToken,
    this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CloudFlareTurnstile(
      siteKey: siteKey,
      baseUrl: baseUrl ?? 'https://lpkt.cn',
      onError: onError,
      onTokenExpired: onError,
      onTokenRecived: onToken,
    );
  }
}
