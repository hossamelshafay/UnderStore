import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:understore/features/auth/data/repos/auth_repo_imp.dart';
import 'package:understore/features/auth/presentation/manager/cubit/auth_cubit.dart';
import '../../../home/presentation/views/home_screen.dart';
import 'package:understore/features/auth/presentation/widgets/styled_input_field.dart';
import 'package:understore/features/auth/presentation/widgets/gradient_button.dart';
import 'package:understore/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:understore/features/auth/presentation/widgets/auth_header.dart';
import 'package:understore/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:understore/features/auth/presentation/widgets/auth_gradient_background.dart';
import 'package:understore/features/auth/presentation/widgets/remember_me_checkbox.dart';
import 'package:understore/features/auth/presentation/widgets/forgot_password_link.dart';
import 'package:understore/features/auth/presentation/widgets/auth_divider.dart';
import 'package:understore/features/auth/presentation/widgets/auth_navigation_prompt.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthCubit? _authCubit;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final authRepo = AuthRepoImp(prefs);
    setState(() => _authCubit = AuthCubit(authRepo));
  }

  void _handleLogin() {
    if (_authCubit == null) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(
        'Please fill in all fields',
        Colors.red,
        Icons.error_outline,
      );
      return;
    }
    if (!email.contains('@')) {
      _showSnackBar(
        'Please enter a valid email address',
        Colors.orange,
        Icons.email_outlined,
      );
      return;
    }
    _authCubit!.signIn(email, password);
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authCubit == null) {
      return const Scaffold(
        body: AuthGradientBackground(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF5145FC)),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => _authCubit!,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is AuthFailure) {
            _showSnackBar(state.message, Colors.red, Icons.error_outline);
          }
        },
        child: Scaffold(
          body: AuthGradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const AuthHeader(
                            title: 'Welcome Back!',
                            subtitle:
                                'Sign in to continue your shopping journey',
                          ),
                          const SizedBox(height: 48),
                          AuthFormCard(
                            child: Column(
                              children: [
                                StyledInputField(
                                  controller: _emailController,
                                  hintText: 'Email Address',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    color: const Color(
                                      0xFF5145FC,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                StyledInputField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: const Color(
                                      0xFF5145FC,
                                    ).withOpacity(0.7),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(
                                        0xFF5145FC,
                                      ).withOpacity(0.7),
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: RememberMeCheckbox(
                                        value: _rememberMe,
                                        onChanged: (value) => setState(
                                          () => _rememberMe = value ?? false,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ForgotPasswordLink(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) => GradientButton(
                                    text: 'Sign In',
                                    onPressed: state is AuthLoading
                                        ? null
                                        : _handleLogin,
                                    isLoading: state is AuthLoading,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                const AuthDivider(),
                                const SizedBox(height: 24),
                                const SocialLoginButtons(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthNavigationPrompt(
                            question: "Don't have an account? ",
                            actionText: 'Sign up',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _authCubit?.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
