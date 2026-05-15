import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';

final class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  // URLs للـ ping — نجرب اتنين عشان مش كل بلد بيوصل كل سيرفر
  static const _pingUrls = [
    'https://1.1.1.1', // Cloudflare — أسرع
    'https://8.8.8.8', // Google DNS — fallback
  ];

  static const _pingTimeout = Duration(seconds: 5);

  const ConnectivityServiceImpl(this._connectivity);

  // ===== checkConnectivity =====
  @override
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();

    /// بتتاكد هل متصل ب wifi او data اصلا ولا لا
    if (!_hasInterface(results)) return false;
    // real internet or not
    return _hasRealInternet();
  }

  // ===== onConnectivityChanged =====
  @override
  Stream<bool> get onConnectivityChanged async* {
    await for (final results in _connectivity.onConnectivityChanged) {
      if (!_hasInterface(results)) {
        yield false;
        continue;
      }
      // عندنا interface — هنأكد إن في إنترنت فعلي
      yield await _hasRealInternet();
    }
  }

  // ===== Helpers =====
  // if this one returns true that means there is wifi or any internet connection (may not real internet (wifi خلصان مثلا))
  bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// بيعمل HTTP HEAD لسيرفرين — لو أي منهم رد = في نت
  Future<bool> _hasRealInternet() async {
    for (final url in _pingUrls) {
      try {
        final request = await HttpClient().headUrl(Uri.parse(url))
          ..persistentConnection = false;

        final response = await request.close().timeout(_pingTimeout);

        await response.drain<void>(); // مهم عشان تحرر الـ connection

        // أي response = في نت (حتى 4xx و 5xx)
        // المهم إن الـ server رد
        if (response.statusCode > 0) return true;
      } on SocketException {
        // مفيش شبكة خالص
        continue;
      } on TimeoutException {
        // الـ request اتأخر — نجرب الـ URL التاني
        continue;
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}
