import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../manager/login_cubit/login_cubit.dart';
import '../manager/login_cubit/login_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.goToHomeByRole(state.user.role);
        }
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.church, size: 72, color: Color(0xFF1A237E)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل البريد' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل كلمة المرور' : null,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                        state is LoginLoading ? null : _onLogin,
                        child: state is LoginLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('دخول'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}