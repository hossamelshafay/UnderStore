import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:understore/features/auth/data/repos/auth_repo_imp.dart';
import 'package:understore/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:understore/features/auth/presentation/widgets/styled_input_field.dart';
import 'package:understore/features/auth/presentation/widgets/gradient_button.dart';
import 'package:understore/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:understore/features/auth/presentation/widgets/auth_header.dart';
import 'package:understore/features/auth/presentation/widgets/auth_gradient_background.dart';
import 'package:understore/features/auth/presentation/widgets/terms_checkbox.dart';
import 'package:understore/features/auth/presentation/widgets/auth_navigation_prompt.dart';
import 'package:understore/features/location/presentation/views/location_screen.dart';
import 'package:understore/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:understore/features/profile/data/repos/profile_repo_imp.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  AuthCubit? _authCubit;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
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

  void _handleSignUp() {
    if (_authCubit == null) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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
    if (password.length < 6) {
      _showSnackBar(
        'Password must be at least 6 characters',
        Colors.orange,
        Icons.lock_outline,
      );
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar(
        'Passwords do not match',
        Colors.red,
        Icons.warning_outlined,
      );
      return;
    }
    if (!_agreeToTerms) {
      _showSnackBar(
        'Please agree to Terms & Conditions',
        Colors.orange,
        Icons.info_outline,
      );
      return;
    }
    _authCubit!.signUp(name, email, password);
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
        listener: (context, state) async {
          if (state is AuthSuccess) {
            // Navigate to location selection first
            final prefs = await SharedPreferences.getInstance();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => ProfileCubit(ProfileRepoImp(prefs)),
                    child: const LocationScreen(
                      currentLocation: '',
                      isFirstTime: true,
                    ),
                  ),
                ),
              );
            }
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
                          const SizedBox(height: 30),
                          const AuthHeader(
                            title: 'Create Account',
                            subtitle:
                                'Sign up to start your shopping experience',
                          ),
                          const SizedBox(height: 36),
                          AuthFormCard(
                            child: Column(
                              children: [
                                StyledInputField(
                                  controller: _nameController,
                                  hintText: 'Full Name',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    color: const Color(
                                      0xFF5145FC,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                const SizedBox(height: 20),
                                StyledInputField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  obscureText: _obscureConfirmPassword,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: const Color(
                                      0xFF5145FC,
                                    ).withOpacity(0.7),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(
                                        0xFF5145FC,
                                      ).withOpacity(0.7),
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TermsCheckbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) => setState(
                                    () => _agreeToTerms = value ?? false,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) => GradientButton(
                                    text: 'Sign Up',
                                    onPressed: state is AuthLoading
                                        ? null
                                        : _handleSignUp,
                                    isLoading: state is AuthLoading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthNavigationPrompt(
                            question: 'Already have an account? ',
                            actionText: 'Sign in',
                            onPressed: () => Navigator.pop(context),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
