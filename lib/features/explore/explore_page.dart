import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../models/movie.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/cinema_card.dart';
import '../../widgets/rating_badge.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ExploreProvider>();

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: CinemaColors.textSecondary),
            onPressed: prov.refresh,
          ),
        ],
      ),
      body: prov.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: CinemaColors.gold))
          : prov.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: CinemaColors.accent, size: 48),
                      const SizedBox(height: 8),
                      Text(prov.error!,
                          style: const TextStyle(
                              color: CinemaColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: prov.refresh,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: CinemaColors.gold,
                  onRefresh: prov.refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      // Quick stats row
                      _QuickStats(stats: prov.stats),
                      const SizedBox(height: 20),

                      // Top Grossing section
                      const _SectionHeader(title: 'Top Box Office', icon: Icons.attach_money_rounded),
                      const SizedBox(height: 12),
                      _TopGrossingList(movies: prov.topGrossing),
                      const SizedBox(height: 20),

                      // Genre distribution
                      const _SectionHeader(
                          title: 'Movies by Genre', icon: Icons.category_rounded),
                      const SizedBox(height: 12),
                      _GenreDistribution(stats: prov.stats),
                      const SizedBox(height: 20),

                      // Decade distribution
                      const _SectionHeader(
                          title: 'Movies by Decade', icon: Icons.timeline_rounded),
                      const SizedBox(height: 12),
                      _DecadeChart(stats: prov.stats),
                      const SizedBox(height: 20),

                      // Rating categories
                      const _SectionHeader(
                          title: 'Rating Categories',
                          icon: Icons.star_half_rounded),
                      const SizedBox(height: 12),
                      _RatingCategories(stats: prov.stats),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }
}

// â”€â”€ Section helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: CinemaColors.gold, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: CinemaColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ],
    );
  }
}

// â”€â”€ Quick Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QuickStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _QuickStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    final avg = (stats['avgRating'] as double? ?? 0.0).toStringAsFixed(2);
    final masterpieces = stats['masterpieces'] ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width > 360 ? null : 110,
            child: _StatCard(label: 'Total Movies', value: '$total', icon: Icons.movie_rounded, color: CinemaColors.info),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width > 360 ? null : 110,
            child: _StatCard(label: 'Avg Rating', value: avg, icon: Icons.star_rounded, color: CinemaColors.gold),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width > 360 ? null : 110,
            child: _StatCard(label: 'Masterpieces', value: '$masterpieces', icon: Icons.workspace_premium_rounded, color: CinemaColors.accent),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CinemaColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          Text(label,
              style: const TextStyle(
                  color: CinemaColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// â”€â”€ Top Grossing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TopGrossingList extends StatelessWidget {
  final List<Movie> movies;
  const _TopGrossingList({required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
          child: Text('No data', style: TextStyle(color: CinemaColors.textMuted)));
    }
    return Column(
      children: movies.asMap().entries.map((e) {
        final m = e.value;
        final rank = e.key + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CinemaCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text('$rank',
                    style: TextStyle(
                        color: rank == 1 ? CinemaColors.gold : CinemaColors.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.center),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.seriesTitle,
                          style: const TextStyle(
                              color: CinemaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('${m.releasedYear ?? "â€”"} Â· ${m.directorName ?? "â€”"}',
                          style: const TextStyle(
                              color: CinemaColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(m.grossFormatted,
                        style: const TextStyle(
                            color: CinemaColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    RatingBadge(rating: m.imdbRating, size: 11),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// â”€â”€ Genre Distribution â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GenreDistribution extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _GenreDistribution({required this.stats});

  @override
  Widget build(BuildContext context) {
    final topGenres = stats['topGenres'] as List? ?? [];
    if (topGenres.isEmpty) return const SizedBox.shrink();

    final maxCount = (topGenres.first.value as int).toDouble();

    return Column(
      children: topGenres.map<Widget>((entry) {
        final name = entry.key as String;
        final count = entry.value as int;
        final ratio = maxCount > 0 ? count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(name,
                    style: const TextStyle(
                        color: CinemaColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: CinemaColors.card,
                    color: CinemaColors.gold,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 34,
                child: Text('$count',
                    style: const TextStyle(
                        color: CinemaColors.textMuted, fontSize: 12),
                    textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// â”€â”€ Decade Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DecadeChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _DecadeChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final byDecade = stats['byDecade'] as Map<String, int>? ?? {};
    if (byDecade.isEmpty) return const SizedBox.shrink();

    final maxVal = byDecade.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CinemaColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Column(
        children: byDecade.entries.map((e) {
          final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(e.key,
                      style: const TextStyle(
                          color: CinemaColors.textMuted, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: CinemaColors.surface,
                      color: CinemaColors.accent,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 34,
                  child: Text('${e.value}',
                      style: const TextStyle(
                          color: CinemaColors.textSecondary, fontSize: 12),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// â”€â”€ Rating Categories â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RatingCategories extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _RatingCategories({required this.stats});

  @override
  Widget build(BuildContext context) {
    final byCategory = stats['byCategory'] as Map<String, int>? ?? {};
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final colors = [
      CinemaColors.gold,
      CinemaColors.success,
      CinemaColors.info,
      CinemaColors.warning,
      CinemaColors.accent,
    ];

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: entries.asMap().entries.map((e) {
        final color = colors[e.key % colors.length];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${e.value.value}',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              Text(e.value.key,
                  style: const TextStyle(
                      color: CinemaColors.textMuted, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

