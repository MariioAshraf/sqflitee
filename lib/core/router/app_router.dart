import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflitee/features/auth/presentation/views/sign_up_screen.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/manager/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/manager/signup_cubit/sign_up_cubit.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/home/presentation/views/priest_home_screen.dart';
import '../../features/home/presentation/views/user_home_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/views/onboarding_screen.dart';
import '../../features/splash/presentation/views/splash_screen.dart';
import '../di/dependency_injection.dart';
import '../services/token_service.dart';
import '../utils/connectivity_toast.dart';

// ════════════════════════════════════════════════════════
//  Route paths
// ════════════════════════════════════════════════════════
sealed class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const userHome = '/home/user';
  static const priestHome = '/home/priest';
  static const signUp = '/signUp';
}

// ════════════════════════════════════════════════════════
//  Router
// ════════════════════════════════════════════════════════
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: ConnectivityToast.navigatorKey,
  debugLogDiagnostics: false,
  routes: [
    // ── Splash ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<SplashCubit>()..checkAuthStatus(),
        child: const SplashScreen(),
      ),
    ),

    // ── Onboarding ───────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, __) => OnboardingScreen(
        onDone: () async {
          await getIt<TokenService>().setOnboardingSeen();
          if (context.mounted) context.goToLogin();
        },
      ),
    ),

    // ── Login ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<LoginCubit>(),
        child: const LoginScreen(),
      ),
    ),

    // ── SignUp ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.signUp,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<SignUpCubit>(), // ← زي LoginCubit بالظبط
        child: const SignUpScreen(),
      ),
    ),

    // ── Home screens ─────────────────────────────────────
    GoRoute(
      path: AppRoutes.userHome,
      builder: (_, __) => const UserHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.priestHome,
      builder: (_, __) => const PriestHomeScreen(),
    ),
  ],
);

// ════════════════════════════════════════════════════════
//  Navigation extension — clean navigation من أي مكان
// ════════════════════════════════════════════════════════
extension AppNavigation on BuildContext {
  void goToOnboarding() => go(AppRoutes.onboarding);

  void goToLogin() => go(AppRoutes.login);

  void goToSignUp() => go(AppRoutes.signUp);

  void goToUserHome() => go(AppRoutes.userHome);

  void goToPriestHome() => go(AppRoutes.priestHome);

  void goToHomeByRole(UserRole role) => switch (role) {
    UserRole.priest => goToPriestHome(),
    UserRole.user => goToUserHome(),
    UserRole.unknown => goToLogin(),
  };
}
