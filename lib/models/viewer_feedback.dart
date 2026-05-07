class ViewerFeedback {
  final int movieId;
  final double? viewerRating;
  final int? viewerMetaScore;

  const ViewerFeedback({
    required this.movieId,
    this.viewerRating,
    this.viewerMetaScore,
  });

  factory ViewerFeedback.fromMap(Map<String, dynamic> map) {
    return ViewerFeedback(
      movieId: (map['movie_id'] as num).toInt(),
      viewerRating: map['viewer_rating'] != null
          ? (map['viewer_rating'] as num).toDouble()
          : null,
      viewerMetaScore: map['viewer_metascore'] != null
          ? (map['viewer_metascore'] as num).toInt()
          : null,
    );
  }
}
