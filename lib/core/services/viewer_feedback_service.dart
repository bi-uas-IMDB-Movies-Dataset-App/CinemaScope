import '../../models/viewer_feedback.dart';
import 'supabase_service.dart';

class ViewerFeedbackService {
  final _sb = SupabaseService();

  String? get _uid => _sb.client.auth.currentUser?.id;

  Future<ViewerFeedback?> fetchMyFeedback(int movieId) async {
    final uid = _uid;
    if (uid == null) return null;

    final row = await _sb.client
        .from('viewer_movie_feedback')
        .select('movie_id, viewer_rating, viewer_metascore')
        .eq('user_id', uid)
        .eq('movie_id', movieId)
        .maybeSingle()
        .timeout(const Duration(seconds: 6));

    if (row == null) return null;
    return ViewerFeedback.fromMap(row);
  }

  Future<void> upsertMyFeedback({
    required int movieId,
    required double viewerRating,
    required int viewerMetaScore,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _sb.client.from('viewer_movie_feedback').upsert({
      'user_id': uid,
      'movie_id': movieId,
      'viewer_rating': viewerRating,
      'viewer_metascore': viewerMetaScore,
    }).timeout(const Duration(seconds: 8));
  }

  Future<void> deleteMyFeedback(int movieId) async {
    final uid = _uid;
    if (uid == null) return;

    await _sb.client
        .from('viewer_movie_feedback')
        .delete()
        .eq('user_id', uid)
        .eq('movie_id', movieId)
        .timeout(const Duration(seconds: 8));
  }
}

