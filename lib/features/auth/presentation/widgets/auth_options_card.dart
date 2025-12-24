import 'package:flutter/material.dart';
import 'auth_action_button.dart';
import 'social_login_buttons.dart';

class AuthOptionsCard extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;

  const AuthOptionsCard({
    super.key,
    required this.onLoginPressed,
    required this.onSignUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF5145FC).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5145FC).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          AuthActionButton(
            text: 'Login',
            onPressed: onLoginPressed,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          AuthActionButton(
            text: 'Sign up',
            onPressed: onSignUpPressed,
            isPrimary: false,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 28),
          const SocialLoginButtons(),
        ],
      ),
    );
  }
}
