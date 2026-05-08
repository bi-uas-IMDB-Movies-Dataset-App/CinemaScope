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
  static const List<String> _dimensions = [
    'Genre',
    'Era',
    'Decade',
    'Director',
    'Certificate',
  ];

  static const List<String> _metrics = [
    'Movie Count',
    'Avg IMDb',
    'Avg Gross',
    'Avg Votes',
  ];

  String _selectedDimension = 'Genre';
  String _selectedMetric = 'Movie Count';
  int _topN = 8;
  double _minRating = 0.0;
  bool _advancedMode = false;

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
        title: const Text('CinemaScope • Explore BI'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _ExploreBackdrop(),
          prov.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: CinemaColors.gold),
                )
              : prov.error != null
                  ? _ErrorView(error: prov.error!, onRetry: prov.refresh)
                  : RefreshIndicator(
                      color: CinemaColors.gold,
                      onRefresh: prov.refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                        children: [
                          const _ExploreTicker(),
                          const SizedBox(height: 10),
                          _QuickStats(stats: prov.stats),
                          const SizedBox(height: 12),
                          const _SectionHeader(
                            title: 'OLAP Lab',
                            icon: Icons.hub_rounded,
                          ),
                          const SizedBox(height: 8),
                          _OlapLab(
                            movies: prov.olapMovies,
                            dimensions: _dimensions,
                            metrics: _metrics,
                            selectedDimension: _selectedDimension,
                            selectedMetric: _selectedMetric,
                            topN: _topN,
                            minRating: _minRating,
                            advancedMode: _advancedMode,
                            onAdvancedModeChanged: (v) =>
                                setState(() => _advancedMode = v),
                            onDimensionChanged: (v) =>
                                setState(() => _selectedDimension = v),
                            onMetricChanged: (v) =>
                                setState(() => _selectedMetric = v),
                            onTopNChanged: (v) => setState(() => _topN = v),
                            onMinRatingChanged: (v) =>
                                setState(() => _minRating = v),
                          ),
                          const SizedBox(height: 12),
                          const _SectionHeader(
                            title: 'Top Box Office',
                            icon: Icons.attach_money_rounded,
                          ),
                          const SizedBox(height: 8),
                          _TopGrossingList(movies: prov.topGrossing),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: CinemaColors.accent, size: 48),
          const SizedBox(height: 8),
          Text(error,
              style: const TextStyle(color: CinemaColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

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
        Text(
          title,
          style: const TextStyle(
            color: CinemaColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _QuickStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    final avg = (stats['avgRating'] as double? ?? 0.0).toStringAsFixed(2);
    final masterpieces = stats['masterpieces'] ?? 0;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatCard(
          label: 'Total Movies',
          value: '$total',
          icon: Icons.movie_rounded,
          color: CinemaColors.info,
        ),
        _StatCard(
          label: 'Avg Rating',
          value: avg,
          icon: Icons.star_rounded,
          color: CinemaColors.gold,
        ),
        _StatCard(
          label: 'Masterpieces',
          value: '$masterpieces',
          icon: Icons.workspace_premium_rounded,
          color: CinemaColors.accent,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CinemaColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label,
              style:
                  const TextStyle(color: CinemaColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _OlapLab extends StatelessWidget {
  static const Map<String, String> _dimensionDescriptions = {
    'Genre':
        'Mengelompokkan film berdasarkan genre. Satu film bisa masuk ke beberapa genre (contoh: Action, Drama), jadi hasilnya cocok untuk melihat minat tema konten.',
    'Era':
        'Mengelompokkan film berdasarkan era waktu yang sudah ditentukan di data (Classic, Retro, Modern, Contemporary). Cocok untuk membaca preferensi lintas generasi.',
    'Decade':
        'Mengelompokkan film per dekade rilis (misalnya 1990s, 2000s). Berguna untuk melihat periode mana yang paling dominan.',
    'Director':
        'Mengelompokkan film berdasarkan sutradara. Cocok untuk melihat performa atau kontribusi nama sutradara tertentu.',
    'Certificate':
        'Mengelompokkan film berdasarkan klasifikasi usia/rating tayang (contoh: PG-13, R, U). Cocok untuk memahami distribusi konten menurut segmentasi audiens.',
  };

  static const Map<String, String> _metricDescriptions = {
    'Movie Count':
        'Jumlah film di setiap kelompok dimension. Gunakan ini saat ingin tahu kategori mana yang paling banyak isi datanya.',
    'Avg IMDb':
        'Rata-rata nilai IMDb per kelompok. Cocok untuk melihat kualitas rata-rata kategori, bukan hanya kuantitas.',
    'Avg Gross':
        'Rata-rata pendapatan box office per kelompok. Membantu membaca potensi komersial kategori berdasarkan data gross.',
    'Avg Votes':
        'Rata-rata jumlah vote IMDb per kelompok. Berguna untuk melihat tingkat popularitas atau engagement audiens.',
  };

  final List<Movie> movies;
  final List<String> dimensions;
  final List<String> metrics;
  final String selectedDimension;
  final String selectedMetric;
  final int topN;
  final double minRating;
  final bool advancedMode;
  final ValueChanged<bool> onAdvancedModeChanged;
  final ValueChanged<String> onDimensionChanged;
  final ValueChanged<String> onMetricChanged;
  final ValueChanged<int> onTopNChanged;
  final ValueChanged<double> onMinRatingChanged;

  const _OlapLab({
    required this.movies,
    required this.dimensions,
    required this.metrics,
    required this.selectedDimension,
    required this.selectedMetric,
    required this.topN,
    required this.minRating,
    required this.advancedMode,
    required this.onAdvancedModeChanged,
    required this.onDimensionChanged,
    required this.onMetricChanged,
    required this.onTopNChanged,
    required this.onMinRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = movies
        .where((m) => (m.imdbRating ?? 0) >= minRating)
        .toList(growable: false);

    final grouped = <String, List<Movie>>{};
    for (final movie in filtered) {
      final keys = _dimensionKeys(movie, selectedDimension);
      for (final key in keys) {
        grouped.putIfAbsent(key, () => []).add(movie);
      }
    }

    final rows = grouped.entries
        .map((entry) => _OlapRow(
              keyName: entry.key,
              movies: entry.value,
              metric: selectedMetric,
            ))
        .toList()
      ..sort((a, b) => b.metricValue.compareTo(a.metricValue));

    final topRows = rows.take(topN).toList();
    final maxMetric = topRows.isEmpty
        ? 1.0
        : topRows
            .map((e) => e.metricValue)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1.0, double.infinity);

    return CinemaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mode Analisis',
                          style: TextStyle(
                            color: CinemaColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ModeToggle(
                          advancedMode: advancedMode,
                          onAdvancedModeChanged: onAdvancedModeChanged,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Text(
                          'Mode Analisis',
                          style: TextStyle(
                            color: CinemaColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        _ModeToggle(
                          advancedMode: advancedMode,
                          onAdvancedModeChanged: onAdvancedModeChanged,
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Panduan Singkat',
            style: TextStyle(
              color: CinemaColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '1) Pilih Dimension untuk cara pengelompokan data.\n2) Pilih Metric untuk nilai yang dibandingkan.\n3) Atur Top N dan Minimum Rating.\n4) Ketuk baris hasil untuk drill-down daftar film.',
            style: TextStyle(
              color: CinemaColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _OlapControls(
            dimensions: dimensions,
            metrics: metrics,
            selectedDimension: selectedDimension,
            selectedMetric: selectedMetric,
            topN: topN,
            minRating: minRating,
            advancedMode: advancedMode,
            onDimensionChanged: onDimensionChanged,
            onMetricChanged: onMetricChanged,
            onTopNChanged: onTopNChanged,
            onMinRatingChanged: onMinRatingChanged,
          ),
          const SizedBox(height: 10),
          _DescriptionCard(
            title: 'Dimension: $selectedDimension',
            body: _dimensionDescriptions[selectedDimension] ?? '-',
            icon: Icons.account_tree_rounded,
          ),
          const SizedBox(height: 8),
          _DescriptionCard(
            title: 'Metric: $selectedMetric',
            body: _metricDescriptions[selectedMetric] ?? '-',
            icon: Icons.stacked_line_chart_rounded,
          ),
          const SizedBox(height: 14),
          Text(
            'Rows: ${filtered.length} movies after filter',
            style: const TextStyle(color: CinemaColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          if (topRows.isEmpty)
            const Text(
              'No OLAP data for this slice.',
              style: TextStyle(color: CinemaColors.textMuted),
            )
          else
            Column(
              children: topRows.map((row) {
                final ratio = (row.metricValue / maxMetric).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _showDrillDown(context, row),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CinemaColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CinemaColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.keyName,
                                  style: const TextStyle(
                                    color: CinemaColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                row.metricLabel,
                                style: const TextStyle(
                                  color: CinemaColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: ratio,
                              color: CinemaColors.gold,
                              backgroundColor: CinemaColors.card,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  List<String> _dimensionKeys(Movie movie, String dimension) {
    switch (dimension) {
      case 'Genre':
        final genres = (movie.genre ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return genres.isEmpty ? ['Unknown'] : genres;
      case 'Era':
        return [movie.era ?? 'Unknown'];
      case 'Decade':
        final year = movie.releasedYear;
        if (year == null) return ['Unknown'];
        return ['${(year ~/ 10) * 10}s'];
      case 'Director':
        return [movie.directorName ?? 'Unknown'];
      case 'Certificate':
        return [movie.certificate ?? 'Unknown'];
      default:
        return ['Unknown'];
    }
  }

  void _showDrillDown(BuildContext context, _OlapRow row) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CinemaColors.card,
      isScrollControlled: true,
      builder: (context) {
        final sorted = [...row.movies]
          ..sort((a, b) => (b.imdbRating ?? 0).compareTo(a.imdbRating ?? 0));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row.keyName} Drill-Down',
                    style: const TextStyle(
                      color: CinemaColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${row.movies.length} movies',
                    style: const TextStyle(
                        color: CinemaColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sorted.length.clamp(0, 20),
                      separatorBuilder: (_, __) =>
                          const Divider(color: CinemaColors.divider, height: 12),
                      itemBuilder: (context, index) {
                        final m = sorted[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.seriesTitle,
                                    style: const TextStyle(
                                      color: CinemaColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${m.releasedYear ?? '-'}  |  ${m.directorName ?? '-'}',
                                    style: const TextStyle(
                                        color: CinemaColors.textMuted,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            RatingBadge(rating: m.imdbRating, size: 11),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OlapControls extends StatelessWidget {
  final List<String> dimensions;
  final List<String> metrics;
  final String selectedDimension;
  final String selectedMetric;
  final int topN;
  final double minRating;
  final bool advancedMode;
  final ValueChanged<String> onDimensionChanged;
  final ValueChanged<String> onMetricChanged;
  final ValueChanged<int> onTopNChanged;
  final ValueChanged<double> onMinRatingChanged;

  const _OlapControls({
    required this.dimensions,
    required this.metrics,
    required this.selectedDimension,
    required this.selectedMetric,
    required this.topN,
    required this.minRating,
    required this.advancedMode,
    required this.onDimensionChanged,
    required this.onMetricChanged,
    required this.onTopNChanged,
    required this.onMinRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    const simpleDimensions = ['Genre', 'Decade', 'Era'];
    const simpleMetrics = ['Movie Count', 'Avg IMDb'];
    final activeDimensions = advancedMode ? dimensions : simpleDimensions;
    final activeMetrics = advancedMode ? metrics : simpleMetrics;

    final safeDimension = activeDimensions.contains(selectedDimension)
        ? selectedDimension
        : activeDimensions.first;
    final safeMetric =
        activeMetrics.contains(selectedMetric) ? selectedMetric : activeMetrics.first;

    if (safeDimension != selectedDimension) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onDimensionChanged(safeDimension);
      });
    }
    if (safeMetric != selectedMetric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMetricChanged(safeMetric);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Cara Analisis',
          style: TextStyle(
            color: CinemaColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DropdownField(
              label: 'Dimension',
              value: safeDimension,
              items: activeDimensions,
              onChanged: onDimensionChanged,
            ),
            _DropdownField(
              label: 'Metric',
              value: safeMetric,
              items: activeMetrics,
              onChanged: onMetricChanged,
            ),
          ],
        ),
        if (advancedMode) ...[
          const SizedBox(height: 10),
          Text(
            'Top N ($topN kategori teratas): menentukan berapa baris ranking yang ditampilkan',
            style:
                const TextStyle(color: CinemaColors.textSecondary, fontSize: 12),
          ),
          Slider(
            value: topN.toDouble(),
            min: 5,
            max: 15,
            divisions: 10,
            label: '$topN',
            activeColor: CinemaColors.gold,
            onChanged: (v) => onTopNChanged(v.round()),
          ),
          Text(
            'Minimum rating (${minRating.toStringAsFixed(1)}): menyaring film di bawah nilai IMDb ini',
            style:
                const TextStyle(color: CinemaColors.textSecondary, fontSize: 12),
          ),
          Slider(
            value: minRating,
            min: 0,
            max: 9,
            divisions: 18,
            label: minRating.toStringAsFixed(1),
            activeColor: CinemaColors.info,
            onChanged: onMinRatingChanged,
          ),
        ] else ...[
          const SizedBox(height: 10),
          const Text(
            'Simple mode memakai filter ramah pemula agar hasil cepat dipahami. Pindah ke Advanced untuk kontrol penuh.',
            style: TextStyle(color: CinemaColors.textMuted, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _DescriptionCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CinemaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: CinemaColors.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CinemaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: CinemaColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: CinemaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: CinemaColors.card,
          style: const TextStyle(color: CinemaColors.textPrimary),
          iconEnabledColor: CinemaColors.textSecondary,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text('$label: $item')))
              .toList(),
        ),
      ),
    );
  }
}

class _ExploreBackdrop extends StatelessWidget {
  const _ExploreBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: _Blob(color: CinemaColors.cyan.withValues(alpha: 0.16), size: 190),
        ),
        Positioned(
          top: 220,
          left: -70,
          child: _Blob(color: CinemaColors.accent.withValues(alpha: 0.15), size: 220),
        ),
        Positioned(
          bottom: -120,
          right: 40,
          child: _Blob(color: CinemaColors.teal.withValues(alpha: 0.15), size: 240),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _ExploreTicker extends StatelessWidget {
  const _ExploreTicker();

  @override
  Widget build(BuildContext context) {
    Widget tag(IconData icon, String text, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CinemaColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: CinemaColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          tag(Icons.query_stats_rounded, 'OLAP Live', CinemaColors.cyan),
          const SizedBox(width: 8),
          tag(Icons.psychology_rounded, 'Smart Slice', CinemaColors.gold),
          const SizedBox(width: 8),
          tag(Icons.trending_up_rounded, 'Trend Radar', CinemaColors.teal),
          const SizedBox(width: 8),
          tag(Icons.data_usage_rounded, 'Metric Boost', CinemaColors.accent),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool advancedMode;
  final ValueChanged<bool> onAdvancedModeChanged;

  const _ModeToggle({
    required this.advancedMode,
    required this.onAdvancedModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CinemaColors.gold.withValues(alpha: 0.18);
          }
          return CinemaColors.surface;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: CinemaColors.divider),
        ),
      ),
      segments: const [
        ButtonSegment<bool>(value: false, label: Text('Simple')),
        ButtonSegment<bool>(value: true, label: Text('Advanced')),
      ],
      selected: {advancedMode},
      onSelectionChanged: (set) => onAdvancedModeChanged(set.first),
    );
  }
}

class _OlapRow {
  final String keyName;
  final List<Movie> movies;
  final String metric;

  _OlapRow({required this.keyName, required this.movies, required this.metric});

  double get metricValue {
    switch (metric) {
      case 'Movie Count':
        return movies.length.toDouble();
      case 'Avg IMDb':
        final vals = movies.where((m) => m.imdbRating != null).map((m) => m.imdbRating!).toList();
        if (vals.isEmpty) return 0;
        return vals.reduce((a, b) => a + b) / vals.length;
      case 'Avg Gross':
        final vals = movies.where((m) => m.gross != null).map((m) => m.gross!).toList();
        if (vals.isEmpty) return 0;
        return vals.reduce((a, b) => a + b) / vals.length;
      case 'Avg Votes':
        final vals = movies.where((m) => m.noOfVotes != null).map((m) => m.noOfVotes!.toDouble()).toList();
        if (vals.isEmpty) return 0;
        return vals.reduce((a, b) => a + b) / vals.length;
      default:
        return 0;
    }
  }

  String get metricLabel {
    switch (metric) {
      case 'Movie Count':
        return movies.length.toString();
      case 'Avg IMDb':
        return metricValue.toStringAsFixed(2);
      case 'Avg Gross':
        if (metricValue >= 1000000) return '\$${(metricValue / 1000000).toStringAsFixed(1)}M';
        return '\$${metricValue.toStringAsFixed(0)}';
      case 'Avg Votes':
        if (metricValue >= 1000000) return '${(metricValue / 1000000).toStringAsFixed(1)}M';
        if (metricValue >= 1000) return '${(metricValue / 1000).toStringAsFixed(1)}K';
        return metricValue.toStringAsFixed(0);
      default:
        return metricValue.toStringAsFixed(2);
    }
  }
}

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
                Text(
                  '$rank',
                  style: TextStyle(
                    color: rank == 1 ? CinemaColors.gold : CinemaColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.seriesTitle,
                        style: const TextStyle(
                          color: CinemaColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${m.releasedYear ?? '-'} | ${m.directorName ?? '-'}',
                        style: const TextStyle(
                          color: CinemaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      m.grossFormatted,
                      style: const TextStyle(
                        color: CinemaColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
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


