import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashNavigateToLogin extends SplashState {
  const SplashNavigateToLogin();
}

final class SplashNavigateToOnboarding extends SplashState {
  const SplashNavigateToOnboarding();
}

final class SplashNavigateToHome extends SplashState {
  final UserRole role;

  const SplashNavigateToHome(this.role);

  @override
  List<Object?> get props => [role];
}
