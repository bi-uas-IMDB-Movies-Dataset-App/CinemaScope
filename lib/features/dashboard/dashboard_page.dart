import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/cinema_colors.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/cinema_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: CinemaColors.textSecondary),
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
                          onPressed: prov.refresh, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: CinemaColors.gold,
                  onRefresh: prov.refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _KpiRow(stats: prov.stats),
                      const SizedBox(height: 20),
                      _RatingDistributionChart(stats: prov.stats),
                      const SizedBox(height: 20),
                      _GenrePieChart(stats: prov.stats),
                      const SizedBox(height: 20),
                      _DecadeBarChart(stats: prov.stats),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }
}

// â”€â”€ KPI Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _KpiRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _KpiRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    final avg = (stats['avgRating'] as double? ?? 0.0);
    final masterpieces = stats['masterpieces'] ?? 0;
    final topGenres = stats['topGenres'] as List? ?? [];
    final topGenreName =
        topGenres.isNotEmpty ? topGenres.first.key as String : 'â€”';

    final kpis = [
      _Kpi('Total Films', '$total', Icons.movie_rounded, CinemaColors.info),
      _Kpi('Avg IMDb', avg.toStringAsFixed(2), Icons.star_rounded,
          CinemaColors.gold),
      _Kpi('Masterpieces', '$masterpieces', Icons.workspace_premium_rounded,
          CinemaColors.accent),
      _Kpi('Top Genre', topGenreName, Icons.category_rounded,
          CinemaColors.success),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 500 ? 2 : 2;
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossCount,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: constraints.maxWidth > 400 ? 1.7 : 1.5,
          children: kpis.map((k) => _KpiCard(kpi: k)).toList(),
        );
      },
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CinemaColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(kpi.value,
              style: TextStyle(
                  color: kpi.color, fontWeight: FontWeight.w800, fontSize: 22),
              overflow: TextOverflow.ellipsis),
          Text(kpi.label,
              style:
                  const TextStyle(color: CinemaColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// â”€â”€ Rating Distribution â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RatingDistributionChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _RatingDistributionChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final byCategory = stats['byCategory'] as Map<String, int>? ?? {};
    if (byCategory.isEmpty) return const SizedBox.shrink();

    // Sort by order
    final order = [
      'Masterpiece (8.5+)', // keep
      'Excellent (8.0-8.4)',
      'Very Good (7.5-7.9)',
      'Good (7.0-7.4)',
      'Average (<7.0)',
    ];
    final entries = order
        .where((k) => byCategory.containsKey(k))
        .map((k) => MapEntry(k, byCategory[k]!))
        .toList();

    final colors = [
      CinemaColors.gold,
      CinemaColors.success,
      CinemaColors.info,
      CinemaColors.warning,
      CinemaColors.accent,
    ];

    return CinemaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: CinemaColors.gold, size: 18),
              SizedBox(width: 8),
              Text('Rating Distribution',
                  style: TextStyle(
                      color: CinemaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: entries.isNotEmpty
                    ? entries
                            .map((e) => e.value.toDouble())
                            .reduce((a, b) => a > b ? a : b) *
                        1.2
                    : 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                            color: CinemaColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        final labels = ['8.5+', '8.0+', '7.5+', '7.0+', '<7.0'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: const TextStyle(
                                color: CinemaColors.textMuted, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: CinemaColors.divider,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((e) {
                  final color = colors[e.key % colors.length];
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: color,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Genre Pie Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GenrePieChart extends StatefulWidget {
  final Map<String, dynamic> stats;
  const _GenrePieChart({required this.stats});
  @override
  State<_GenrePieChart> createState() => _GenrePieChartState();
}

class _GenrePieChartState extends State<_GenrePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final topGenres = widget.stats['topGenres'] as List? ?? [];
    if (topGenres.isEmpty) return const SizedBox.shrink();

    final colors = [
      CinemaColors.gold,
      CinemaColors.accent,
      CinemaColors.info,
      CinemaColors.success,
      CinemaColors.warning,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
    ];

    final total = topGenres.fold<int>(0, (s, e) => s + (e.value as int));

    return CinemaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: CinemaColors.gold, size: 18),
              SizedBox(width: 8),
              Text('Top Genres',
                  style: TextStyle(
                      color: CinemaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final pieSize = constraints.maxWidth > 400 ? 180.0 : 140.0;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    height: pieSize,
                    width: pieSize,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              _touchedIndex =
                                  response?.touchedSection?.touchedSectionIndex ??
                                      -1;
                            });
                          },
                        ),
                        sections: topGenres.asMap().entries.map((e) {
                          final color = colors[e.key % colors.length];
                          final pct =
                              total > 0 ? e.value.value / total * 100 : 0.0;
                          final isTouched = e.key == _touchedIndex;
                          return PieChartSectionData(
                            color: color,
                            value: e.value.value.toDouble(),
                            title: isTouched
                                ? '${pct.toStringAsFixed(1)}%'
                                : '',
                            radius: isTouched ? pieSize * 0.45 : pieSize * 0.38,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                          );
                        }).toList(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: pieSize * 0.15,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth > 400 ? 220 : constraints.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topGenres.asMap().entries.map((e) {
                        final color = colors[e.key % colors.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value.key as String,
                                  style: const TextStyle(
                                      color: CinemaColors.textSecondary,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${e.value.value}',
                                style: const TextStyle(
                                    color: CinemaColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Decade Bar Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DecadeBarChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _DecadeBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final byDecade = stats['byDecade'] as Map<String, int>? ?? {};
    if (byDecade.isEmpty) return const SizedBox.shrink();

    final entries = byDecade.entries.toList();
    final maxY =
        entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) *
            1.2;

    return CinemaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: CinemaColors.gold, size: 18),
              SizedBox(width: 8),
              Text('Movies by Decade',
                  style: TextStyle(
                      color: CinemaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: entries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: CinemaColors.gold,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: CinemaColors.gold,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: CinemaColors.gold.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                            color: CinemaColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Transform.rotate(
                          angle: -0.4,
                          child: Text(
                            entries[idx].key,
                            style: const TextStyle(
                                color: CinemaColors.textMuted, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: CinemaColors.divider,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
