import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) return;

    if (_isRegister) {
      await auth.register(email, pass);
      if (mounted && auth.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! You can now log in.'),
            backgroundColor: CinemaColors.success,
          ),
        );
        setState(() => _isRegister = false);
      }
    } else {
      await auth.login(email, pass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Brand
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CinemaColors.gold,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: CinemaColors.gold.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.movie_filter_rounded,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'CinemaScope',
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: CinemaColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Discover the world\'s greatest films',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: CinemaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CinemaColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CinemaColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isRegister ? 'Create Account' : 'Welcome Back',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: CinemaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRegister
                              ? 'Sign up to explore top movies'
                              : 'Sign in to your account',
                          style: const TextStyle(color: CinemaColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // Email
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: CinemaColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: CinemaColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(color: CinemaColors.textPrimary),
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: CinemaColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: CinemaColors.textMuted,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),

                        // Error
                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CinemaColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CinemaColors.accent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: CinemaColors.accent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    auth.error!,
                                    style: const TextStyle(
                                      color: CinemaColors.accentSoft,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Submit button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submit,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(_isRegister ? 'Create Account' : 'Sign In'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegister
                                  ? 'Already have an account? '
                                  : 'Don\'t have an account? ',
                              style: const TextStyle(color: CinemaColors.textMuted, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                _isRegister = !_isRegister;
                              }),
                              child: Text(
                                _isRegister ? 'Sign In' : 'Register',
                                style: const TextStyle(
                                  color: CinemaColors.gold,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

