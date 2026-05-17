import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'connectivity_service.dart';

final class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  static const _pingUrls    = ['https://1.1.1.1', 'https://8.8.8.8'];
  static const _pingTimeout = Duration(seconds: 5); // من 2 لـ 5

  const ConnectivityServiceImpl(this._connectivity);

  @override
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (!_hasInterface(results)) return false;
    return _hasRealInternet();
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .debounceTime(const Duration(milliseconds: 800))
        .asyncMap((results) async {
      if (!_hasInterface(results)) return false;
      return _hasRealInternet();
    })
        .distinct();
  }

  bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> _hasRealInternet() async {
    try {
      return await Future.any([
        ..._pingUrls.map(_pingUrl),
        Future.delayed(const Duration(seconds: 12), () => false),
      ]);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _pingUrl(String url) async {
    try {
      final request = await HttpClient()
          .getUrl(Uri.parse(url)) // ← get بدل head — أكثر استجابة على الداتا الضعيفة
        ..persistentConnection = false;

      final response = await request.close().timeout(_pingTimeout);
      await response.drain<void>();
      return response.statusCode > 0;
    } catch (_) {
      return false;
    }
  }
}