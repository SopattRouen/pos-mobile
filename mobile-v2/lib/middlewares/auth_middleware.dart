import 'package:flutter/material.dart';
import 'package:mobile/page/p2_welcome/welcome.dart';
import 'package:mobile/page/p3_auth/login.dart';

import 'package:mobile/provider/global/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthMiddleware extends StatelessWidget {
  final Widget child;
  const AuthMiddleware({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isChecking) {
          // Show splash screen while checking
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isFirstTime) {
          return const WelcomeScreen();
        }

        if (auth.isLoggedIn) {
          return child;
        }

        return const Login();
      },
    );
  }
}
