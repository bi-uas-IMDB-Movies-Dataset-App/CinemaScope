import 'package:flutter/material.dart';
import '../core/services/movie_service.dart';
import '../models/movie.dart';

class AdminMovieProvider extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<Movie> movies = [];
  bool isLoading = false;
  bool isSaving = false;
  String query = '';
  String? error;

  Future<void> loadMovies({String? search}) async {
    if (search != null) query = search;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      movies = await _service.fetchAdminMovies(query: query);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createMovie({
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
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await _service.createMovie(
        seriesTitle: seriesTitle,
        releasedYear: releasedYear,
        certificate: certificate,
        runtimeMin: runtimeMin,
        genre: genre,
        imdbRating: imdbRating,
        metaScore: metaScore,
        noOfVotes: noOfVotes,
        gross: gross,
        directorName: directorName,
        overview: overview,
      );
      await loadMovies();
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> updateMovie({
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
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await _service.updateMovie(
        movieId: movieId,
        seriesTitle: seriesTitle,
        releasedYear: releasedYear,
        certificate: certificate,
        runtimeMin: runtimeMin,
        genre: genre,
        imdbRating: imdbRating,
        metaScore: metaScore,
        noOfVotes: noOfVotes,
        gross: gross,
        directorName: directorName,
        overview: overview,
      );
      await loadMovies();
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> deleteMovie(int movieId) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteMovie(movieId);
      await loadMovies();
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

