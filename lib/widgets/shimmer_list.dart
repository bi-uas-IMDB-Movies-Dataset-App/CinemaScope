import 'package:flutter/material.dart';
import '../core/constants/cinema_colors.dart';

/// A shimmer-animated list of placeholder movie tiles.
/// Use while loading movie lists from Supabase.
class ShimmerMovieList extends StatelessWidget {
  final int itemCount;
  const ShimmerMovieList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: itemCount,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _ShimmerTile(),
      ),
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 84,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              CinemaColors.card,
              CinemaColors.cardHover,
              CinemaColors.card,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CinemaColors.divider),
        ),
        child: Row(
          children: [
            // Rank placeholder
            _box(28, 20),
            const SizedBox(width: 10),
            // Poster placeholder
            _box(44, 56, radius: 7),
            const SizedBox(width: 14),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _box(double.infinity, 13),
                  const SizedBox(height: 8),
                  _box(140, 10),
                  const SizedBox(height: 6),
                  _box(100, 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Rating placeholder
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(40, 14),
                const SizedBox(height: 6),
                _box(28, 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 6}) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: CinemaColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Single shimmer stat-card placeholder (used in Dashboard/Explore)
class ShimmerStatCard extends StatelessWidget {
  final double height;
  const ShimmerStatCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return _PulseBox(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: CinemaColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CinemaColors.divider),
        ),
      ),
    );
  }
}

class _PulseBox extends StatefulWidget {
  final Widget child;
  const _PulseBox({required this.child});

  @override
  State<_PulseBox> createState() => _PulseBoxState();
}

class _PulseBoxState extends State<_PulseBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: widget.child);
}

