class Movie {
  final int movieId;
  final String seriesTitle;
  final int? releasedYear;
  final String? certificate;
  final double? runtimeMin;
  final String? genre;
  final double? imdbRating;
  final double? metaScore;
  final int? noOfVotes;
  final double? gross;
  final String? directorName;
  final String? era;
  final String? ratingCategory;
  final String? overview;

  Movie({
    required this.movieId,
    required this.seriesTitle,
    this.releasedYear,
    this.certificate,
    this.runtimeMin,
    this.genre,
    this.imdbRating,
    this.metaScore,
    this.noOfVotes,
    this.gross,
    this.directorName,
    this.era,
    this.ratingCategory,
    this.overview,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      movieId: (map['movie_id'] as num).toInt(),
      seriesTitle: map['series_title']?.toString() ?? '',
      releasedYear: map['released_year'] != null
          ? (map['released_year'] as num).toInt()
          : null,
      certificate: map['certificate']?.toString(),
      runtimeMin: map['runtime_min'] != null
          ? (map['runtime_min'] as num).toDouble()
          : null,
      genre: map['genre']?.toString(),
      imdbRating: map['imdb_rating'] != null
          ? (map['imdb_rating'] as num).toDouble()
          : null,
      metaScore: map['meta_score'] != null
          ? (map['meta_score'] as num).toDouble()
          : null,
      noOfVotes: map['no_of_votes'] != null
          ? (map['no_of_votes'] as num).toInt()
          : null,
      gross: map['gross'] != null ? (map['gross'] as num).toDouble() : null,
      directorName: map['director_name']?.toString(),
      era: map['era']?.toString(),
      ratingCategory: map['rating_category']?.toString(),
      overview: map['overview']?.toString(),
    );
  }

  /// First genre tag (e.g. "Action" from "Action, Adventure")
  String get primaryGenre => genre?.split(',').first.trim() ?? 'Unknown';

  /// Formatted runtime (e.g. "2h 22m")
  String get runtimeFormatted {
    if (runtimeMin == null) return '—';
    final h = runtimeMin! ~/ 60;
    final m = runtimeMin!.toInt() % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  /// Formatted votes (e.g. "2.3M" / "234K")
  String get votesFormatted {
    if (noOfVotes == null) return '—';
    if (noOfVotes! >= 1000000) {
      return '${(noOfVotes! / 1000000).toStringAsFixed(1)}M';
    }
    if (noOfVotes! >= 1000) {
      return '${(noOfVotes! / 1000).toStringAsFixed(0)}K';
    }
    return noOfVotes.toString();
  }

  /// Formatted gross (e.g. "\$134.9M")
  String get grossFormatted {
    if (gross == null) return '—';
    if (gross! >= 1000000000) {
      return '\$${(gross! / 1000000000).toStringAsFixed(1)}B';
    }
    if (gross! >= 1000000) {
      return '\$${(gross! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${gross!.toStringAsFixed(0)}';
  }
}

