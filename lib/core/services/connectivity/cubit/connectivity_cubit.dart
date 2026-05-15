import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';


import '../connectivity_service.dart';
import 'connectivity_state.dart';

final class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 500);

  ConnectivityCubit(this._connectivityService)
      : super(const ConnectivityState.initial()) {
    _init();
  }

  Future<void> _init() async {
    // الـ check الأولي — مش محتاج debounce هنا
    final isConnected = await _connectivityService.checkConnectivity();
    if (isClosed) return;

    emit(
      isConnected
          ? const ConnectivityState.connected()
          : const ConnectivityState.disconnected(),
    );

    // الاستماع للتغييرات مع debounce
    _subscription = _connectivityService.onConnectivityChanged.listen(
      _onConnectionChanged,
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
      },
    );
  }

  void _onConnectionChanged(bool isConnected) {
    // إلغاء الـ timer القديم لو في واحد شغال
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () {
      if (isClosed) return;
      emit(
        isConnected
            ? const ConnectivityState.connected()
            : const ConnectivityState.disconnected(),
      );
    });
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}