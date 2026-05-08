import 'package:flutter/material.dart';

import '../../core/constants/cinema_colors.dart';

class InAppSplash extends StatelessWidget {
  final String? subtitle;

  const InAppSplash({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemaColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/splash.png',
                    width: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 220,
                      height: 220,
                      color: CinemaColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        size: 72,
                        color: CinemaColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: CinemaColors.gold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CinemaColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

