import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
import '../../domain/use_cases/signup_params.dart';
import '../manager/signup_cubit/sign_up_cubit.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SignUpView();
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _nationalFocus = FocusNode();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalCtrl = TextEditingController();

  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _phoneCtrl,
      _nationalCtrl,
    ]) {
      c.dispose();
    }
    for (final f in [
      _nameFocus,
      _emailFocus,
      _passwordFocus,
      _phoneFocus,
      _nationalFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<SignUpCubit>().signUp(
      params: SignUpParams(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text.trim(),
        nationalId: _nationalCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: const Color(0xFFB94040),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }

          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الحساب بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            context.goToLogin();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F4EF),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: CustomScrollView(
              slivers: [
                _buildHeader(context),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              _buildField(
                                controller: _nameCtrl,
                                focus: _nameFocus,
                                nextFocus: _emailFocus,
                                label: 'الاسم الكامل',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'أدخل اسمك'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _emailCtrl,
                                focus: _emailFocus,
                                nextFocus: _passwordFocus,
                                label: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'أدخل بريدك الإلكتروني';
                                  if (!RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w]{2,}$',
                                  ).hasMatch(v.trim())) {
                                    return 'بريد إلكتروني غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _phoneCtrl,
                                focus: _phoneFocus,
                                nextFocus: _nationalFocus,
                                label: 'رقم الهاتف',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'أدخل رقم هاتفك';
                                  if (v.trim().length < 10)
                                    return 'رقم هاتف غير صحيح';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _nationalCtrl,
                                focus: _nationalFocus,
                                label: 'الرقم القومي',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'أدخل رقمك القومي';
                                  if (v.trim().length != 14)
                                    return 'الرقم القومي 14 رقم';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              _buildSubmitButton(),
                              const SizedBox(height: 20),
                              _buildLoginLink(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1A3A5C),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A3A5C), Color(0xFF2D6A9F)],
                ),
              ),
            ),
            // دوائر زخرفية
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // النص
            const Positioned(
              bottom: 30,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'أنشئ حسابك للانضمام إلى مجتمع الكنيسة',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Text Field ───────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? nextFocus,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
      onFieldSubmitted:
          onFieldSubmitted ??
          (_) {
            if (nextFocus != null)
              FocusScope.of(context).requestFocus(nextFocus);
          },
      validator: validator,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  // ── Password Field ───────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    return StatefulBuilder(
      builder: (_, setState) => TextFormField(
        controller: _passwordCtrl,
        focusNode: _passwordFocus,
        obscureText: _obscurePassword,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
        onFieldSubmitted: (_) =>
            FocusScope.of(context).requestFocus(_phoneFocus),
        validator: (v) {
          if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
          if (v.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
          return null;
        },
        decoration: _inputDecoration(
          label: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF718096),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  // ── Input Decoration ─────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Cairo',
        color: Color(0xFF718096),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF1A3A5C), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2D6A9F), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB94040), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB94040), width: 2),
      ),
      errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        final isLoading = state is SignUpLoading;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A3A5C), Color(0xFF2D6A9F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3A5C).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : _submit,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Login Link ───────────────────────────────────────────────────────────
  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'عندك حساب بالفعل؟',
          style: TextStyle(
            color: Color(0xFF718096),
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => context.goToLogin(),
          child: const Text(
            'سجل دخولك',
            style: TextStyle(
              color: Color(0xFF1A3A5C),
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
