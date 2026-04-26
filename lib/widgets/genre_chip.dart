import 'package:flutter/material.dart';
import '../core/constants/cinema_colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? CinemaColors.gold.withValues(alpha: 0.15)
              : CinemaColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? CinemaColors.gold : CinemaColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? CinemaColors.gold : CinemaColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

