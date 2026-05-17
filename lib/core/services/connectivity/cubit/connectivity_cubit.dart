import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../connectivity_service.dart';
import 'connectivity_state.dart';

final class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._connectivityService)
      : super(const ConnectivityState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (isClosed) return;

    emit(
      isConnected
          ? const ConnectivityState.connected()
          : const ConnectivityState.disconnected(),
    );

    _subscription = _connectivityService.onConnectivityChanged.listen(
      _onConnectionChanged,
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
      },
    );
  }

  void _onConnectionChanged(bool isConnected) {
    if (isClosed) return;
    emit(
      isConnected
          ? const ConnectivityState.connected()
          : const ConnectivityState.disconnected(),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}