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
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CinemaColors.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: CinemaColors.gold.withValues(alpha: 0.06),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: CinemaColors.divider),
          ),
          child: child,
        ),
      ),
    );
  }
}

