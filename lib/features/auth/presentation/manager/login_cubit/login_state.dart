import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/user_entity.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class LoginFailure extends LoginState {
  final Failure failure;
  const LoginFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}