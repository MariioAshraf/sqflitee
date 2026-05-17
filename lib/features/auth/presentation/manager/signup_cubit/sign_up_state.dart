// lib/features/auth/presentation/sign_up/cubit/sign_up_state.dart

part of 'sign_up_cubit.dart';

sealed class SignUpState {
  const SignUpState();
}

final class SignUpInitial   extends SignUpState { const SignUpInitial(); }
final class SignUpLoading   extends SignUpState { const SignUpLoading(); }
final class SignUpSuccess   extends SignUpState { const SignUpSuccess(); }

final class SignUpFailure extends SignUpState {
  final String message;
  const SignUpFailure(this.message);
}