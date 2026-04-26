import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/cinema_colors.dart';
import '../../models/movie.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/movie_tile.dart';
import '../../widgets/shimmer_list.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});
  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WatchlistProvider>();

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          if (prov.movies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CinemaColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: CinemaColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${prov.movies.length} films',
                    style: const TextStyle(
                      color: CinemaColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: prov.isLoading
          ? const ShimmerMovieList()
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
                          onPressed: prov.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : prov.movies.isEmpty
                  ? _EmptyWatchlist()
                  : RefreshIndicator(
                      color: CinemaColors.gold,
                      onRefresh: prov.load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        itemCount: prov.movies.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _WatchlistTile(movie: prov.movies[i]),
                        ),
                      ),
                    ),
    );
  }
}

// â”€â”€ Empty state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EmptyWatchlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: CinemaColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: CinemaColors.divider, width: 2),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: CinemaColors.textMuted,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: CinemaColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the bookmark icon on any movie\nto save it here',
            style: TextStyle(color: CinemaColors.textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Watchlist tile with remove button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _WatchlistTile extends StatelessWidget {
  final Movie movie;
  const _WatchlistTile({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(movie.movieId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: CinemaColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CinemaColors.accent.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: CinemaColors.accentSoft, size: 24),
      ),
      onDismissed: (_) {
        context.read<WatchlistProvider>().toggle(movie.movieId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${movie.seriesTitle}" removed from watchlist'),
            backgroundColor: CinemaColors.card,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: MovieTile(movie: movie),
    );
  }
}
