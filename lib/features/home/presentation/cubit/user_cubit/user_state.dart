part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final List<OldUserModel> users;

  UserLoaded(this.users);
}

class UserLoading extends UserState {}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
