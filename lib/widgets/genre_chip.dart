import 'package:flutter/material.dart';

import '../core/constants/cinema_colors.dart';
import '../core/constants/genre_colors.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = label.toLowerCase() == 'all';
    final colors = isAll
        ? [CinemaColors.gold.withValues(alpha: 0.22), CinemaColors.surface]
        : GenreColors.gradient(label);
    final chipAccent = isAll ? CinemaColors.gold : GenreColors.accent(label);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    colors.first.withValues(alpha: 0.9),
                    colors.last.withValues(alpha: 0.85),
                  ]
                : [
                    colors.first.withValues(alpha: 0.34),
                    colors.last.withValues(alpha: 0.26),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipAccent : CinemaColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? chipAccent : CinemaColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
