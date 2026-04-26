import 'package:flutter/material.dart';
import '../core/services/movie_service.dart';
import '../models/movie.dart';

class ExploreProvider extends ChangeNotifier {
  final MovieService _service = MovieService();

  Map<String, dynamic> stats = {};
  bool isLoading = false;
  String? error;

  Future<void> loadStats() async {
    if (stats.isNotEmpty) return; // already loaded
    _setLoading(true);
    error = null;
    try {
      stats = await _service.fetchDashboardStats();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    stats = {};
    await loadStats();
  }

  List<Movie> get topGrossing =>
      (stats['topGrossing'] as List<Movie>? ?? []);

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}
