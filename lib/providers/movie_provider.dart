import 'package:flutter/material.dart';
import '../core/services/movie_service.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<Movie> topMovies = [];
  List<Movie> searchResults = [];
  List<String> genres = [];
  bool isLoading = false;
  bool isSearching = false;
  String? error;
  String _searchQuery = '';
  String? _selectedGenre;

  String get searchQuery => _searchQuery;
  String? get selectedGenre => _selectedGenre;

  Future<void> loadTopMovies() async {
    _setLoading(true);
    error = null;
    try {
      topMovies = await _service.fetchTopMovies(limit: 100);
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGenres() async {
    try {
      genres = await _service.fetchGenres();
    } catch (_) {}
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    try {
      searchResults = await _service.searchMovies(query.trim());
    } catch (e) {
      error = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> filterByGenre(String? genre) async {
    _selectedGenre = genre;
    if (genre == null) {
      await loadTopMovies();
      return;
    }
    _setLoading(true);
    error = null;
    try {
      topMovies = await _service.fetchByGenre(genre, limit: 100);
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    searchResults = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}
