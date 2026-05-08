import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../models/movie.dart';
import '../../providers/admin_movie_provider.dart';

class AdminMoviesPage extends StatefulWidget {
  const AdminMoviesPage({super.key});

  @override
  State<AdminMoviesPage> createState() => _AdminMoviesPageState();
}

class _AdminMoviesPageState extends State<AdminMoviesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMovieProvider>().loadMovies();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEditor({Movie? movie}) async {
    final provider = context.read<AdminMovieProvider>();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _MovieEditorDialog(movie: movie),
    );
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: CinemaColors.success,
      ),
    );
    provider.loadMovies(search: _searchCtrl.text);
  }

  Future<void> _deleteMovie(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CinemaColors.surface,
        title: const Text('Delete Movie',
            style: TextStyle(color: CinemaColors.textPrimary)),
        content: Text(
          'Delete "${movie.seriesTitle}"?',
          style: const TextStyle(color: CinemaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: CinemaColors.accent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<AdminMovieProvider>();
    final error = await provider.deleteMovie(movie.movieId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Movie deleted'),
        backgroundColor: error == null ? CinemaColors.success : CinemaColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMovieProvider>();
    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: const Text('CinemaScope • Manage Movies'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: CinemaColors.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Movie'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => provider.loadMovies(search: v),
              style: const TextStyle(color: CinemaColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search title...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: CinemaColors.textMuted),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.loadMovies(search: '');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: CinemaColors.gold),
                  )
                : provider.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: CinemaColors.accentSoft),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : provider.movies.isEmpty
                        ? const Center(
                            child: Text(
                              'No movies found',
                              style: TextStyle(color: CinemaColors.textMuted),
                            ),
                          )
                        : RefreshIndicator(
                            color: CinemaColors.gold,
                            onRefresh: () => provider.loadMovies(search: _searchCtrl.text),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                              itemCount: provider.movies.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final movie = provider.movies[i];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: CinemaColors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: CinemaColors.divider),
                                  ),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: Text(
                                      movie.seriesTitle,
                                      style: const TextStyle(
                                        color: CinemaColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '#${movie.movieId}  ${movie.releasedYear ?? '-'}  ${movie.imdbRating?.toStringAsFixed(1) ?? '-'}',
                                      style: const TextStyle(color: CinemaColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: SizedBox(
                                      width: 92,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit',
                                            icon: const Icon(Icons.edit_rounded,
                                                color: CinemaColors.gold),
                                            onPressed: () => _openEditor(movie: movie),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete',
                                            icon: const Icon(Icons.delete_rounded,
                                                color: CinemaColors.accent),
                                            onPressed: () => _deleteMovie(movie),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _MovieEditorDialog extends StatefulWidget {
  final Movie? movie;
  const _MovieEditorDialog({this.movie});

  @override
  State<_MovieEditorDialog> createState() => _MovieEditorDialogState();
}

class _MovieEditorDialogState extends State<_MovieEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _certificateCtrl;
  late final TextEditingController _runtimeCtrl;
  late final TextEditingController _genreCtrl;
  late final TextEditingController _imdbCtrl;
  late final TextEditingController _metaCtrl;
  late final TextEditingController _votesCtrl;
  late final TextEditingController _grossCtrl;
  late final TextEditingController _directorCtrl;
  late final TextEditingController _overviewCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleCtrl = TextEditingController(text: m?.seriesTitle ?? '');
    _yearCtrl = TextEditingController(text: m?.releasedYear?.toString() ?? '');
    _certificateCtrl = TextEditingController(text: m?.certificate ?? '');
    _runtimeCtrl = TextEditingController(text: m?.runtimeMin?.toString() ?? '');
    _genreCtrl = TextEditingController(text: m?.genre ?? '');
    _imdbCtrl = TextEditingController(text: m?.imdbRating?.toString() ?? '');
    _metaCtrl = TextEditingController(text: m?.metaScore?.toString() ?? '');
    _votesCtrl = TextEditingController(text: m?.noOfVotes?.toString() ?? '');
    _grossCtrl = TextEditingController(text: m?.gross?.toString() ?? '');
    _directorCtrl = TextEditingController(text: m?.directorName ?? '');
    _overviewCtrl = TextEditingController(text: m?.overview ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _certificateCtrl.dispose();
    _runtimeCtrl.dispose();
    _genreCtrl.dispose();
    _imdbCtrl.dispose();
    _metaCtrl.dispose();
    _votesCtrl.dispose();
    _grossCtrl.dispose();
    _directorCtrl.dispose();
    _overviewCtrl.dispose();
    super.dispose();
  }

  int? _toInt(String value) => value.trim().isEmpty ? null : int.tryParse(value.trim());
  double? _toDouble(String value) =>
      value.trim().isEmpty ? null : double.tryParse(value.trim());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<AdminMovieProvider>();

    final title = _titleCtrl.text.trim();
    String? error;
    if (widget.movie == null) {
      error = await provider.createMovie(
        seriesTitle: title,
        releasedYear: _toInt(_yearCtrl.text),
        certificate: _certificateCtrl.text,
        runtimeMin: _toDouble(_runtimeCtrl.text),
        genre: _genreCtrl.text,
        imdbRating: _toDouble(_imdbCtrl.text),
        metaScore: _toDouble(_metaCtrl.text),
        noOfVotes: _toInt(_votesCtrl.text),
        gross: _toDouble(_grossCtrl.text),
        directorName: _directorCtrl.text,
        overview: _overviewCtrl.text,
      );
    } else {
      error = await provider.updateMovie(
        movieId: widget.movie!.movieId,
        seriesTitle: title,
        releasedYear: _toInt(_yearCtrl.text),
        certificate: _certificateCtrl.text,
        runtimeMin: _toDouble(_runtimeCtrl.text),
        genre: _genreCtrl.text,
        imdbRating: _toDouble(_imdbCtrl.text),
        metaScore: _toDouble(_metaCtrl.text),
        noOfVotes: _toInt(_votesCtrl.text),
        gross: _toDouble(_grossCtrl.text),
        directorName: _directorCtrl.text,
        overview: _overviewCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: CinemaColors.accent),
      );
      return;
    }
    Navigator.pop(context, widget.movie == null ? 'Movie created' : 'Movie updated');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;
    return AlertDialog(
      backgroundColor: CinemaColors.surface,
      title: Text(
        isEdit ? 'Edit Movie' : 'Create Movie',
        style: const TextStyle(color: CinemaColors.textPrimary),
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_titleCtrl, 'Title', required: true),
                _field(_yearCtrl, 'Released Year', type: TextInputType.number),
                _field(_certificateCtrl, 'Certificate'),
                _field(_runtimeCtrl, 'Runtime (minutes)',
                    type: const TextInputType.numberWithOptions(decimal: true)),
                _field(_genreCtrl, 'Genre'),
                _field(_imdbCtrl, 'IMDb Rating',
                    type: const TextInputType.numberWithOptions(decimal: true)),
                _field(_metaCtrl, 'Meta Score',
                    type: const TextInputType.numberWithOptions(decimal: true)),
                _field(_votesCtrl, 'Votes', type: TextInputType.number),
                _field(_grossCtrl, 'Gross',
                    type: const TextInputType.numberWithOptions(decimal: true)),
                _field(_directorCtrl, 'Director'),
                _field(_overviewCtrl, 'Overview', maxLines: 4),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? type,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(color: CinemaColors.textPrimary),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}


