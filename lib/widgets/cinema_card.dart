import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/cinema_colors.dart';

class CinemaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  const CinemaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: CinemaColors.cyan.withValues(alpha: 0.1),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CinemaColors.glass,
                    CinemaColors.card.withValues(alpha: 0.84),
                  ],
                ),
                border: Border.all(
                  color: CinemaColors.cyan.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CinemaColors.cyan.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

