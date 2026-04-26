import 'package:flutter_test/flutter_test.dart';
import 'package:cinemascope/models/movie.dart';

void main() {
  group('Movie model', () {
    final sampleMap = {
      'movie_id': 1,
      'series_title': 'The Shawshank Redemption',
      'released_year': 1994,
      'certificate': 'A',
      'runtime_min': 142.0,
      'genre': 'Drama',
      'imdb_rating': 9.3,
      'meta_score': 80.0,
      'no_of_votes': 2343110,
      'gross': 28341469.0,
      'director_name': 'Frank Darabont',
      'era': 'Modern 90s',
      'rating_category': 'Masterpiece (8.5+)',
      'overview': 'Two imprisoned men bond over a number of years.',
    };

    test('fromMap parses all fields correctly', () {
      final movie = Movie.fromMap(sampleMap);
      expect(movie.movieId, equals(1));
      expect(movie.seriesTitle, equals('The Shawshank Redemption'));
      expect(movie.releasedYear, equals(1994));
      expect(movie.imdbRating, closeTo(9.3, 0.01));
      expect(movie.noOfVotes, equals(2343110));
      expect(movie.directorName, equals('Frank Darabont'));
    });

    test('runtimeFormatted returns correct format', () {
      final movie = Movie.fromMap(sampleMap);
      expect(movie.runtimeFormatted, equals('2h 22m'));
    });

    test('runtimeFormatted handles minutes only', () {
      final m = Movie.fromMap({...sampleMap, 'runtime_min': 45.0});
      expect(m.runtimeFormatted, equals('45m'));
    });

    test('votesFormatted formats millions', () {
      final movie = Movie.fromMap(sampleMap);
      expect(movie.votesFormatted, contains('M'));
    });

    test('votesFormatted formats thousands', () {
      final m = Movie.fromMap({...sampleMap, 'no_of_votes': 234000});
      expect(m.votesFormatted, equals('234K'));
    });

    test('grossFormatted returns M suffix for millions', () {
      final movie = Movie.fromMap(sampleMap);
      expect(movie.grossFormatted, contains('M'));
      expect(movie.grossFormatted, startsWith(r'$'));
    });

    test('grossFormatted returns B suffix for billions', () {
      final m = Movie.fromMap({...sampleMap, 'gross': 2500000000.0});
      expect(m.grossFormatted, contains('B'));
    });

    test('primaryGenre returns first genre', () {
      final movie = Movie.fromMap(sampleMap);
      expect(movie.primaryGenre, equals('Drama'));
    });

    test('primaryGenre handles multi-genre', () {
      final m =
          Movie.fromMap({...sampleMap, 'genre': 'Action, Adventure, Sci-Fi'});
      expect(m.primaryGenre, equals('Action'));
    });

    test('handles null optional fields gracefully', () {
      final sparse = Movie.fromMap({
        'movie_id': 99,
        'series_title': 'Test Film',
      });
      expect(sparse.runtimeFormatted, equals('—'));
      expect(sparse.votesFormatted, equals('—'));
      expect(sparse.grossFormatted, equals('—'));
      expect(sparse.primaryGenre, equals('Unknown'));
    });
  });
}
