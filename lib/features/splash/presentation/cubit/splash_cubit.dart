import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/token_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  final TokenService _tokenService;

  SplashCubit(this._tokenService) : super(const SplashInitial());

  Future<void> checkAuthStatus() async {
    await Future.wait([
      _determineRoute(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
  }

  Future<void> _determineRoute() async {
    try {
      // ── Onboarding ──────────────────────────────────
      final hasSeenOnboarding = await _tokenService.hasSeenOnboarding();

      if (!hasSeenOnboarding) {
        emit(const SplashNavigateToOnboarding());
        return;
      }

      // ── Auth ─────────────────────────────────────────
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        emit(const SplashNavigateToLogin());
        return;
      }

      // ── Role ─────────────────────────────────────────

      final roleStr = await _tokenService.getUserRole();
      final role = (roleStr ?? '').toUserRole;

      emit(SplashNavigateToHome(role));
    } catch (_) {
      emit(const SplashNavigateToLogin());
    }
  }
}
