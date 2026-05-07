import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_page.dart';
import 'in_app_splash.dart';
import 'login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void>? _profileFuture;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return StreamBuilder(
      stream: auth.authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const InAppSplash(subtitle: 'Preparing CinemaScope...');
        }

        if (!auth.isLoggedIn) {
          _profileFuture = null;
          return const LoginPage();
        }

        _profileFuture ??= auth.loadProfile();
        return FutureBuilder(
          future: _profileFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const InAppSplash(subtitle: 'Loading your profile...');
            }
            if (auth.profile == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      Text(auth.error ?? 'Failed to load profile'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _profileFuture = auth.loadProfile();
                        }),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const HomePage();
          },
        );
      },
    );
  }
}
