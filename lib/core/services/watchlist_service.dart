import 'supabase_service.dart';
import '../../models/movie.dart';

class WatchlistService {
  final _sb = SupabaseService();

  String? get _uid => _sb.client.auth.currentUser?.id;

  Future<List<Movie>> fetchWatchlist() async {
    final uid = _uid;
    if (uid == null) return [];
    final data = await _sb.client
        .from('watchlist')
        .select('movie_id, fact_movies(*)')
        .eq('user_id', uid)
        .order('added_at', ascending: false);
    return (data as List).map((row) {
      final m = row['fact_movies'] as Map<String, dynamic>;
      return Movie.fromMap(m);
    }).toList();
  }

  Future<Set<int>> fetchWatchlistIds() async {
    final uid = _uid;
    if (uid == null) return {};
    final data = await _sb.client
        .from('watchlist')
        .select('movie_id')
        .eq('user_id', uid);
    return (data as List).map((r) => (r['movie_id'] as num).toInt()).toSet();
  }

  Future<void> add(int movieId) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.client.from('watchlist').upsert({
      'user_id': uid,
      'movie_id': movieId,
    });
  }

  Future<void> remove(int movieId) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.client
        .from('watchlist')
        .delete()
        .eq('user_id', uid)
        .eq('movie_id', movieId);
  }

  Future<void> toggle(int movieId, bool currentlyInList) async {
    if (currentlyInList) {
      await remove(movieId);
    } else {
      await add(movieId);
    }
  }
}

