import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/cinema_theme.dart';
import 'features/auth/auth_wrapper.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_movie_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/watchlist_provider.dart';

class CinemaScopeApp extends StatelessWidget {
  const CinemaScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminMovieProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CinemaScope',
        theme: CinemaTheme.dark(),
        home: const AuthWrapper(),
      ),
    );
  }
}

