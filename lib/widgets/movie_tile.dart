import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/cinema_colors.dart';
import '../core/services/viewer_feedback_service.dart';
import '../models/movie.dart';
import '../models/viewer_feedback.dart';
import '../providers/auth_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/rating_badge.dart';

class MovieTile extends StatelessWidget {
  final Movie movie;
  final int? rank;
  final VoidCallback? onTap;

  const MovieTile({super.key, required this.movie, this.rank, this.onTap});

  @override
  Widget build(BuildContext context) {
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap ?? () => _openDetail(context, movie),
        borderRadius: BorderRadius.circular(14),
        splashColor: CinemaColors.cyan.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: 0.88),
                CinemaColors.surface.withValues(alpha: 0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CinemaColors.divider),
            boxShadow: [
              BoxShadow(
                color: CinemaColors.cyan.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank number
              if (rank != null)
                SizedBox(
                  width: 32,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rank! <= 10 ? CinemaColors.cyan : CinemaColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: rank! <= 9 ? 18 : 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (rank != null) const SizedBox(width: 10),

              // Poster placeholder
              _PosterPlaceholder(title: movie.seriesTitle),
              const SizedBox(width: 14),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movie.seriesTitle,
                            style: const TextStyle(
                              color: CinemaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.auto_awesome_rounded, color: CinemaColors.gold, size: 14),
                        const SizedBox(width: 4),
                        const Icon(Icons.bolt_rounded, color: CinemaColors.cyan, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(movie: movie),
                    const SizedBox(height: 4),
                    if (movie.genre != null)
                      Text(
                        movie.genre!,
                        style: const TextStyle(
                          color: CinemaColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Rating + Bookmark
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingBadge(rating: movie.imdbRating),
                  const SizedBox(height: 4),
                  Text(
                    movie.votesFormatted,
                    style: const TextStyle(
                        color: CinemaColors.textMuted, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  _BookmarkButton(movieId: movie.movieId),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Poster placeholder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PosterPlaceholder extends StatelessWidget {
  final String title;
  const _PosterPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CinemaColors.surface,
            CinemaColors.divider,
          ],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: CinemaColors.gold,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Meta row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MetaRow extends StatelessWidget {
  final Movie movie;
  const _MetaRow({required this.movie});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (movie.releasedYear != null) parts.add('${movie.releasedYear}');
    if (movie.runtimeFormatted != '—') parts.add(movie.runtimeFormatted);
    if (movie.certificate != null) parts.add(movie.certificate!);

    return Wrap(
      spacing: 6,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts
          .asMap()
          .entries
          .expand<Widget>((e) => [
                Text(
                  e.value,
                  style: const TextStyle(
                    color: CinemaColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (e.key < parts.length - 1)
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: CinemaColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
              ])
          .toList(),
    );
  }
}

// â”€â”€ Bookmark button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BookmarkButton extends StatelessWidget {
  final int movieId;
  const _BookmarkButton({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WatchlistProvider>();
    final saved = prov.isInWatchlist(movieId);

    return GestureDetector(
      onTap: () async {
        await prov.toggle(movieId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                saved ? 'Removed from watchlist' : 'Added to watchlist',
                style: const TextStyle(color: CinemaColors.textPrimary),
              ),
              backgroundColor: CinemaColors.card,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 1, milliseconds: 500),
            ),
          );
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(saved),
          color: saved ? CinemaColors.gold : CinemaColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}

// â”€â”€ Open full-screen detail â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
void _openDetail(BuildContext context, Movie movie) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
  );
}

// ============================================================================
// MOVIE DETAIL PAGE (full screen)
// ============================================================================
class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ViewerFeedbackService _feedbackService = ViewerFeedbackService();
  ViewerFeedback? _myFeedback;
  bool _feedbackLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyFeedback();
  }

  Future<void> _loadMyFeedback() async {
    setState(() => _feedbackLoading = true);
    try {
      final feedback =
          await _feedbackService.fetchMyFeedback(widget.movie.movieId);
      if (!mounted) return;
      setState(() {
        _myFeedback = feedback;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _myFeedback = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _feedbackLoading = false;
        });
      }
    }
  }

  Future<void> _openFeedbackEditor() async {
    final initialRating = _myFeedback?.viewerRating ?? 7.5;
    final initialMeta = _myFeedback?.viewerMetaScore?.toDouble() ?? 75.0;
    double rating = (initialRating * 2).round() / 2;
    double meta = initialMeta.clamp(0, 100);

    final action = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: CinemaColors.surface,
          title: const Text('Your Viewer Review',
              style: TextStyle(color: CinemaColors.textPrimary)),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Viewer Rating: ${rating.toStringAsFixed(1)} / 10',
                    style: const TextStyle(color: CinemaColors.textSecondary)),
                Slider(
                  value: rating,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  activeColor: CinemaColors.gold,
                  onChanged: (v) =>
                      setStateDialog(() => rating = (v * 2).round() / 2),
                ),
                const SizedBox(height: 8),
                Text('Viewer Metascore: ${meta.round()} / 100',
                    style: const TextStyle(color: CinemaColors.textSecondary)),
                Slider(
                  value: meta,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: CinemaColors.info,
                  onChanged: (v) => setStateDialog(() => meta = v),
                ),
              ],
            ),
          ),
          actions: [
            if (_myFeedback != null)
              TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                child: const Text('Delete My Review',
                    style: TextStyle(color: CinemaColors.accent)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, 'save:$rating:${meta.round()}'),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (action == null || action == 'cancel') return;
    try {
      if (action == 'delete') {
        await _feedbackService.deleteMyFeedback(widget.movie.movieId);
      } else if (action.startsWith('save:')) {
        final parts = action.split(':');
        final parsedRating = double.tryParse(parts[1]) ?? rating;
        final parsedMeta = int.tryParse(parts[2]) ?? meta.round();
        await _feedbackService.upsertMyFeedback(
          movieId: widget.movie.movieId,
          viewerRating: parsedRating,
          viewerMetaScore: parsedMeta,
        );
      }
      await _loadMyFeedback();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viewer feedback saved'),
          backgroundColor: CinemaColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: CinemaColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final saved =
        context.watch<WatchlistProvider>().isInWatchlist(movie.movieId);
    final isViewer =
        (context.watch<AuthProvider>().profile?.role.toLowerCase() ?? 'viewer') ==
            'viewer';

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      body: CustomScrollView(
        slivers: [
          // â”€â”€ Hero App Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: CinemaColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: CinemaColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Bookmark toggle in appbar
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(saved),
                      color: saved
                          ? CinemaColors.gold
                          : CinemaColors.textSecondary,
                    ),
                  ),
                  onPressed: () =>
                      context.read<WatchlistProvider>().toggle(movie.movieId),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBackground(movie: movie),
            ),
          ),

          // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + year
                  Text(
                    movie.seriesTitle,
                    style: const TextStyle(
                      color: CinemaColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _MovieSubtitle(movie: movie),
                  const SizedBox(height: 16),

                  // Rating row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _RatingRow(
                      movie: movie,
                      isViewer: isViewer,
                      feedback: _myFeedback,
                      feedbackLoading: _feedbackLoading,
                      onEditFeedback: _openFeedbackEditor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Genres
                  if (movie.genre != null) ...[
                    _GenreRow(genres: movie.genre!),
                    const SizedBox(height: 20),
                  ],

                  // Overview
                  if (movie.overview != null &&
                      movie.overview!.trim().isNotEmpty) ...[
                    const _SectionLabel('Overview'),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview!,
                      style: const TextStyle(
                        color: CinemaColors.textSecondary,
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Director
                  if (movie.directorName != null) ...[
                    const _SectionLabel('Director'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: CinemaColors.card,
                          child: Icon(Icons.person_rounded,
                              color: CinemaColors.textMuted, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          movie.directorName!,
                          style: const TextStyle(
                            color: CinemaColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stats grid
                  const _SectionLabel('Details'),
                  const SizedBox(height: 12),
                  _StatsGrid(movie: movie),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Hero background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _HeroBackground extends StatelessWidget {
  final Movie movie;
  const _HeroBackground({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background with first-letter art
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CinemaColors.card,
                CinemaColors.surface,
              ],
            ),
          ),
        ),

        // Big letter watermark
        Center(
          child: Text(
            movie.seriesTitle.isNotEmpty
                ? movie.seriesTitle[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: CinemaColors.gold.withValues(alpha: 0.08),
              fontSize: 180,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        // Poster card centred
        Center(
          child: Container(
            width: 100,
            height: 148,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [CinemaColors.card, CinemaColors.divider],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: CinemaColors.gold.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                movie.seriesTitle.isNotEmpty
                    ? movie.seriesTitle[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: CinemaColors.gold,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),

        // Bottom fade
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
                colors: [
                  Colors.transparent,
                  CinemaColors.bg,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Subtitle: year · runtime · certificate â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MovieSubtitle extends StatelessWidget {
  final Movie movie;
  const _MovieSubtitle({required this.movie});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (movie.releasedYear != null) parts.add('${movie.releasedYear}');
    if (movie.runtimeFormatted != '—') parts.add(movie.runtimeFormatted);
    if (movie.certificate != null) parts.add(movie.certificate!);
    if (movie.era != null) parts.add(movie.era!);

    return Wrap(
      spacing: 6,
      children: parts
          .asMap()
          .entries
          .expand<Widget>((e) => [
                Text(e.value,
                    style: const TextStyle(
                        color: CinemaColors.textMuted, fontSize: 13)),
                if (e.key < parts.length - 1)
                  const Text('·',
                      style: TextStyle(
                          color: CinemaColors.textMuted, fontSize: 13)),
              ])
          .toList(),
    );
  }
}

// â”€â”€ IMDb + Metascore rating row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RatingRow extends StatelessWidget {
  final Movie movie;
  final bool isViewer;
  final ViewerFeedback? feedback;
  final bool feedbackLoading;
  final VoidCallback onEditFeedback;
  const _RatingRow({
    required this.movie,
    required this.isViewer,
    required this.feedback,
    required this.feedbackLoading,
    required this.onEditFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // IMDb rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: CinemaColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CinemaColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: CinemaColors.gold, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    movie.imdbRating?.toStringAsFixed(1) ?? '—',
                    style: const TextStyle(
                      color: CinemaColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  const Text(
                    '/10',
                    style:
                        TextStyle(color: CinemaColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${movie.votesFormatted} votes',
                style: const TextStyle(
                    color: CinemaColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),

        // Metascore
        if (movie.metaScore != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _metaColor(movie.metaScore!).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _metaColor(movie.metaScore!).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  movie.metaScore!.toStringAsFixed(0),
                  style: TextStyle(
                    color: _metaColor(movie.metaScore!),
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'Metascore',
                  style: TextStyle(color: CinemaColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],

        // Category badge
        if (movie.ratingCategory != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CinemaColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: CinemaColors.info.withValues(alpha: 0.25)),
            ),
            child: Text(
              movie.ratingCategory!,
              style: const TextStyle(
                color: CinemaColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (isViewer) ...[
          const SizedBox(width: 12),
          InkWell(
            onTap: onEditFeedback,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CinemaColors.card,
                borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CinemaColors.divider),
            boxShadow: [
              BoxShadow(
                color: CinemaColors.cyan.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rating: ${feedback?.viewerRating?.toStringAsFixed(1) ?? '-'}',
                    style: const TextStyle(
                      color: CinemaColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your Meta: ${feedback?.viewerMetaScore?.toString() ?? '-'}',
                    style: const TextStyle(
                      color: CinemaColors.info,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feedbackLoading ? 'Loading...' : 'Tap to rate',
                    style: const TextStyle(
                      color: CinemaColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _metaColor(double score) {
    if (score >= 80) return CinemaColors.success;
    if (score >= 60) return CinemaColors.warning;
    return CinemaColors.accent;
  }
}

// â”€â”€ Genre row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GenreRow extends StatelessWidget {
  final String genres;
  const _GenreRow({required this.genres});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres
          .split(',')
          .map((g) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: CinemaColors.divider),
                ),
                child: Text(
                  g.trim(),
                  style: const TextStyle(
                    color: CinemaColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// â”€â”€ Stats grid 2Ã—N â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StatsGrid extends StatelessWidget {
  final Movie movie;
  const _StatsGrid({required this.movie});

  @override
  Widget build(BuildContext context) {
    final items = <_StatItem>[
      if (movie.releasedYear != null)
        _StatItem(
            Icons.calendar_today_rounded, 'Year', '${movie.releasedYear}'),
      _StatItem(Icons.timer_rounded, 'Runtime', movie.runtimeFormatted),
      if (movie.certificate != null)
        _StatItem(Icons.verified_rounded, 'Certificate', movie.certificate!),
      if (movie.gross != null)
        _StatItem(
            Icons.attach_money_rounded, 'Box Office', movie.grossFormatted),
      if (movie.noOfVotes != null)
        _StatItem(Icons.how_to_vote_rounded, 'Votes', movie.votesFormatted),
      if (movie.era != null)
        _StatItem(Icons.history_rounded, 'Era', movie.era!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(this.icon, this.label, this.value);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CinemaColors.card,
        borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CinemaColors.divider),
            boxShadow: [
              BoxShadow(
                color: CinemaColors.cyan.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Row(
        children: [
          Icon(item.icon, color: CinemaColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.label,
                    style: const TextStyle(
                        color: CinemaColors.textMuted, fontSize: 11)),
                const SizedBox(height: 3),
                Text(item.value,
                    style: const TextStyle(
                        color: CinemaColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Section label â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CinemaColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}





