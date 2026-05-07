import 'package:flutter/material.dart';
import '../core/services/movie_service.dart';
import '../models/movie.dart';

class ExploreProvider extends ChangeNotifier {
  final MovieService _service = MovieService();

  Map<String, dynamic> stats = {};
  List<Movie> olapMovies = [];
  bool isLoading = false;
  String? error;

  Future<void> loadStats() async {
    if (stats.isNotEmpty && olapMovies.isNotEmpty) return;
    _setLoading(true);
    error = null;
    try {
      stats = await _service.fetchDashboardStats();
      olapMovies = await _service.fetchOlapMovies();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    stats = {};
    olapMovies = [];
    await loadStats();
  }

  List<Movie> get topGrossing => (stats['topGrossing'] as List<Movie>? ?? []);

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}
