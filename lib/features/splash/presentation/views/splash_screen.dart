import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import '../../../../core/router/app_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) => switch (state) {
        SplashNavigateToOnboarding() => context.goToOnboarding(),
        SplashNavigateToLogin()        => context.goToLogin(),
        SplashNavigateToHome(:final role) => context.goToHomeByRole(role),
        SplashInitial()                => null,
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A237E), // اللون بتاع الكنيسة
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // استبدل بـ logo الكنيسة
              const Icon(Icons.church, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'اسم الكنيسة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}