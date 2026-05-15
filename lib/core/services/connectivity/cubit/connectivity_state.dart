import 'package:equatable/equatable.dart';

enum ConnectionStatus { initial, connected, disconnected }

final class ConnectivityState extends Equatable {
  final ConnectionStatus status;

  const ConnectivityState._({required this.status});

  const ConnectivityState.initial() : this._(status: ConnectionStatus.initial);

  const ConnectivityState.connected()
    : this._(status: ConnectionStatus.connected);

  const ConnectivityState.disconnected()
    : this._(status: ConnectionStatus.disconnected);

  bool get isConnected => status == ConnectionStatus.connected;

  bool get isInitial => status == ConnectionStatus.initial;

  @override
  List<Object?> get props => [status];
}
