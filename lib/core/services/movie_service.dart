import 'supabase_service.dart';
import '../../models/movie.dart';

class MovieService {
  final _sb = SupabaseService();

  /// Fetch top-rated movies (home feed)
  Future<List<Movie>> fetchTopMovies({int limit = 50}) async {
    final data = await _sb.client
        .from('fact_movies')
        .select()
        .order('imdb_rating', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Movie.fromMap(e)).toList();
  }

  /// Lightweight dataset for client-side OLAP interactions.
  Future<List<Movie>> fetchOlapMovies({int limit = 1000}) async {
    final data = await _sb.client
        .from('fact_movies')
        .select(
            'movie_id, series_title, released_year, certificate, runtime_min, genre, imdb_rating, meta_score, no_of_votes, gross, director_name, era, rating_category, overview')
        .order('imdb_rating', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Movie.fromMap(e)).toList();
  }

  /// Search by title
  Future<List<Movie>> searchMovies(String query) async {
    final data = await _sb.client
        .from('fact_movies')
        .select()
        .ilike('series_title', '%$query%')
        .order('imdb_rating', ascending: false)
        .limit(30);
    return (data as List).map((e) => Movie.fromMap(e)).toList();
  }

  /// Filter by genre
  Future<List<Movie>> fetchByGenre(String genre, {int limit = 50}) async {
    final data = await _sb.client
        .from('fact_movies')
        .select()
        .ilike('genre', '%$genre%')
        .order('imdb_rating', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Movie.fromMap(e)).toList();
  }

  /// All distinct genres from dim_genre
  Future<List<String>> fetchGenres() async {
    final data =
        await _sb.client.from('dim_genre').select('genre_name').order('genre_name');
    return (data as List).map((e) => e['genre_name'].toString()).toList();
  }

  /// Fetch dashboard stats
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final movies = await _sb.client.from('fact_movies').select();
    final list = (movies as List).map((e) => Movie.fromMap(e)).toList();

    if (list.isEmpty) return {};

    // Total movies
    final total = list.length;

    // Average IMDb rating
    final validRatings = list.where((m) => m.imdbRating != null).toList();
    final avgRating = validRatings.isEmpty
        ? 0.0
        : validRatings.map((m) => m.imdbRating!).reduce((a, b) => a + b) /
            validRatings.length;

    // Movies by decade
    final Map<String, int> byDecade = {};
    for (final m in list) {
      final year = m.releasedYear ?? 0;
      if (year == 0) continue;
      final decade = '${(year ~/ 10) * 10}s';
      byDecade[decade] = (byDecade[decade] ?? 0) + 1;
    }

    // Movies by rating category
    final Map<String, int> byCategory = {};
    for (final m in list) {
      final cat = m.ratingCategory ?? 'Unknown';
      byCategory[cat] = (byCategory[cat] ?? 0) + 1;
    }

    // Movies by genre (top 8)
    final Map<String, int> byGenre = {};
    for (final m in list) {
      final genres = (m.genre ?? '').split(',').map((g) => g.trim()).toList();
      for (final g in genres) {
        if (g.isNotEmpty) byGenre[g] = (byGenre[g] ?? 0) + 1;
      }
    }
    final topGenres = byGenre.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top grossing
    final withGross = list.where((m) => m.gross != null).toList()
      ..sort((a, b) => b.gross!.compareTo(a.gross!));
    final topGrossing = withGross.take(5).toList();

    // Top rated masterpieces
    final masterpieces = list
        .where((m) => m.imdbRating != null && m.imdbRating! >= 8.5)
        .length;

    return {
      'total': total,
      'avgRating': avgRating,
      'byDecade': Map.fromEntries(
          (byDecade.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))),
      'byCategory': byCategory,
      'topGenres': topGenres.take(8).toList(),
      'topGrossing': topGrossing,
      'masterpieces': masterpieces,
    };
  }

  Future<List<Movie>> fetchAdminMovies({String query = '', int limit = 300}) async {
    final trimmed = query.trim();
    final data = trimmed.isEmpty
        ? await _sb.client
            .from('fact_movies')
            .select()
            .order('movie_id', ascending: false)
            .limit(limit)
        : await _sb.client
            .from('fact_movies')
            .select()
            .ilike('series_title', '%$trimmed%')
            .order('movie_id', ascending: false)
            .limit(limit);
    return (data as List).map((e) => Movie.fromMap(e)).toList();
  }

  Future<void> createMovie({
    required String seriesTitle,
    int? releasedYear,
    String? certificate,
    double? runtimeMin,
    String? genre,
    double? imdbRating,
    double? metaScore,
    int? noOfVotes,
    double? gross,
    String? directorName,
    String? overview,
  }) async {
    final payload = _cleanPayload({
      'series_title': seriesTitle.trim(),
      'released_year': releasedYear,
      'certificate': _cleanString(certificate),
      'runtime_min': runtimeMin,
      'genre': _cleanString(genre),
      'imdb_rating': imdbRating,
      'meta_score': metaScore,
      'no_of_votes': noOfVotes,
      'gross': gross,
      'director_name': _cleanString(directorName),
      'era': _deriveEra(releasedYear),
      'rating_category': _deriveRatingCategory(imdbRating),
      'overview': _cleanString(overview),
    });
    await _sb.client.from('fact_movies').insert(payload);
  }

  Future<void> updateMovie({
    required int movieId,
    required String seriesTitle,
    int? releasedYear,
    String? certificate,
    double? runtimeMin,
    String? genre,
    double? imdbRating,
    double? metaScore,
    int? noOfVotes,
    double? gross,
    String? directorName,
    String? overview,
  }) async {
    final payload = _cleanPayload({
      'series_title': seriesTitle.trim(),
      'released_year': releasedYear,
      'certificate': _cleanString(certificate),
      'runtime_min': runtimeMin,
      'genre': _cleanString(genre),
      'imdb_rating': imdbRating,
      'meta_score': metaScore,
      'no_of_votes': noOfVotes,
      'gross': gross,
      'director_name': _cleanString(directorName),
      'era': _deriveEra(releasedYear),
      'rating_category': _deriveRatingCategory(imdbRating),
      'overview': _cleanString(overview),
    });
    await _sb.client.from('fact_movies').update(payload).eq('movie_id', movieId);
  }

  Future<void> deleteMovie(int movieId) async {
    await _sb.client.from('fact_movies').delete().eq('movie_id', movieId);
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    payload.removeWhere((_, value) => value == null);
    return payload;
  }

  String? _cleanString(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  String? _deriveEra(int? year) {
    if (year == null) return null;
    if (year < 1970) return 'Classic (< 1970)';
    if (year < 1990) return 'Retro (1970-1989)';
    if (year < 2000) return 'Modern 90s';
    if (year < 2010) return 'Modern 2000s';
    return 'Contemporary (2010+)';
  }

  String? _deriveRatingCategory(double? rating) {
    if (rating == null) return null;
    if (rating >= 8.5) return 'Masterpiece (8.5+)';
    if (rating >= 8.0) return 'Excellent (8.0-8.4)';
    if (rating >= 7.5) return 'Very Good (7.5-7.9)';
    if (rating >= 7.0) return 'Good (7.0-7.4)';
    return 'Average (<7.0)';
  }
}

