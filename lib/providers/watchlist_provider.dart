import 'package:flutter/material.dart';
import '../core/services/watchlist_service.dart';
import '../models/movie.dart';

class WatchlistProvider extends ChangeNotifier {
  final WatchlistService _service = WatchlistService();

  List<Movie> movies = [];
  Set<int> ids = {};
  bool isLoading = false;
  String? error;

  bool isInWatchlist(int movieId) => ids.contains(movieId);

  Future<void> load() async {
    _setLoading(true);
    error = null;
    try {
      movies = await _service.fetchWatchlist();
      ids = movies.map((m) => m.movieId).toSet();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadIds() async {
    try {
      ids = await _service.fetchWatchlistIds();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle(int movieId) async {
    final wasIn = ids.contains(movieId);
    // Optimistic update
    if (wasIn) {
      ids.remove(movieId);
      movies.removeWhere((m) => m.movieId == movieId);
    } else {
      ids.add(movieId);
    }
    notifyListeners();

    try {
      await _service.toggle(movieId, wasIn);
      // Reload to get full movie data if added
      if (!wasIn) {
        movies = await _service.fetchWatchlist();
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      if (wasIn) {
        ids.add(movieId);
      } else {
        ids.remove(movieId);
      }
      error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}

