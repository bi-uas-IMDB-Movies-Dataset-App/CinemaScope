import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/movie_tile.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});
  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MovieProvider>();
      if (p.topMovies.isEmpty) p.loadTopMovies();
      if (p.genres.isEmpty) p.loadGenres();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchActive = !_searchActive);
    if (!_searchActive) {
      _searchCtrl.clear();
      context.read<MovieProvider>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MovieProvider>();
    final isSearchMode = _searchActive && _searchCtrl.text.isNotEmpty;
    final movies = isSearchMode ? prov.searchResults : prov.topMovies;

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: _searchActive
            ? Row(
                children: [
                  const Text(
                    'CinemaScope',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: CinemaColors.textPrimary),
                      cursorColor: CinemaColors.gold,
                      decoration: const InputDecoration(
                        hintText: 'Search movies...',
                        hintStyle: TextStyle(color: CinemaColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (q) => prov.search(q),
                    ),
                  ),
                ],
              )
            : const Text('CinemaScope • Movies'),
        actions: [
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close : Icons.search_rounded,
              color: CinemaColors.textSecondary,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Genre filter strip
          if (!_searchActive && prov.genres.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GenreChip(
                      label: 'All',
                      selected: prov.selectedGenre == null,
                      onTap: () => prov.filterByGenre(null),
                    ),
                  ),
                  ...prov.genres.map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GenreChip(
                          label: g,
                          selected: prov.selectedGenre == g,
                          onTap: () => prov.filterByGenre(g),
                        ),
                      )),
                ],
              ),
            ),

          // List
          Expanded(
            child: prov.isLoading
                ? const ShimmerMovieList()
                : prov.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: CinemaColors.accent, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load: ${prov.error}',
                              style: const TextStyle(
                                  color: CinemaColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: prov.loadTopMovies,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : movies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.movie_outlined,
                                    color: CinemaColors.textMuted, size: 56),
                                const SizedBox(height: 12),
                                Text(
                                  isSearchMode
                                      ? 'No results for "${_searchCtrl.text}"'
                                      : 'No movies found',
                                  style: const TextStyle(
                                      color: CinemaColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: CinemaColors.gold,
                            onRefresh: prov.loadTopMovies,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: movies.length,
                              itemBuilder: (_, i) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: MovieTile(
                                  movie: movies[i],
                                  rank: isSearchMode ? null : i + 1,
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
