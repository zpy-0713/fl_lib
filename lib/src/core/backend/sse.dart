part of 'api.dart';

/// {@template sse_listener}
/// SSE Listener
///
/// ```dart
/// void listener(String data) {
///  dprint(data);
/// }
/// ```
/// {@endtemplate}
typedef SseListener = void Function(String data);

/// SSE Subscription
typedef SseSub = StreamSubscription<String>;

/// SSE Apis
///
/// {@template sse_apis_listen}
/// Usage:
/// ```dart
/// final sub = await SseApis.listen((data) {
///  dprint(data);
/// });
/// ```
/// {@endtemplate}
abstract final class SseApi {
  /// {'chan': `Set<SseListener>`}
  static final _listeners = <String, Set<SseListener>>{};

  /// {'chan': `SseSub`}
  static final _subs = <String, SseSub>{};

  /// Add a listener to a channel.
  ///
  /// In common usage, you should use [listen] instead.
  /// Or if you want to manage the subscription by yourself, you can use this method.
  static void addListener(String chan, SseListener listener) {
    _listeners.putIfAbsent(chan, () => <SseListener>{}).add(listener);
  }

  /// Remove a listener from a channel.
  ///
  /// If there is no listener left in the channel, the subscription will be canceled.
  /// Or you can call [removeChan] to remove the channel and its subscription.
  static void removeListener(String chan, SseListener listener) {
    _listeners[chan]?.remove(listener);
  }

  /// Remove a channel and its subscription(default).
  ///
  /// - [includeSubs]: whether to cancel the subscription.
  static Future<void> removeChan(
    String chan, {
    bool includeSubs = true,
  }) async {
    _listeners.remove(chan);
    if (includeSubs) {
      await _subs.remove(chan)?.cancel();
    }
  }

  /// Remove all listeners and subscriptions.
  static Future<void> removeAll({bool includeSubs = true}) async {
    if (includeSubs) {
      for (final sub in _subs.values) {
        await sub.cancel();
      }
      _subs.clear();
    }
    _listeners.clear();
  }

  /// Listen to a channel.
  ///
  /// {@macro sse_apis_listen}
  static Future<SseSub> listen({
    /// {@macro sse_listener}
    required SseListener listener,

    /// Channel name, eg.: 'file', 'user'
    required String chan,
  }) async {
    addListener(chan, listener);

    final sub_ = _subs[chan];
    if (sub_ != null) {
      return sub_;
    }

    const url = '${ApiUrls.sse}/listen';
    final resp = await myDio.get(
      url,
      queryParameters: {'type': chan},
      options: Options(
        headers: UserApi.authHeaders,
        responseType: ResponseType.stream,
      ),
    );

    final stream = (resp.data as Stream<List<int>>)
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    late final SseSub sub;
    sub = stream.listen(
      (line) {
        dprint(line);
        if (line.isEmpty) return;
        if (!line.startsWith('data: ')) return;
        final data = line.substring(6).trimRight();
        final listeners = _listeners[chan];
        if (listeners == null) {
          sub.cancel();
          _subs.remove(chan);
          return;
        }
        for (final listener in listeners) {
          listener(data);
        }
      },
      onDone: () {
        _subs.remove(chan);
      },
      onError: (e) {
        dprint('SSE error: $e');
        _subs.remove(chan);
      },
    );

    _subs[chan] = sub;
    return sub;
  }
}
