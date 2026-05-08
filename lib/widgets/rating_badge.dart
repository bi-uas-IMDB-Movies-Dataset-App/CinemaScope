import 'package:flutter/material.dart';
import '../core/constants/cinema_colors.dart';

class RatingBadge extends StatelessWidget {
  final double? rating;
  final double size;

  const RatingBadge({super.key, this.rating, this.size = 13});

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: CinemaColors.gold, size: size + 2),
        const SizedBox(width: 3),
        Text(
          rating!.toStringAsFixed(1),
          style: TextStyle(
            color: CinemaColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: size,
          ),
        ),
      ],
    );
  }
}

