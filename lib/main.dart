import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/constants/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0A0E1A),
          body: Center(
            child: Text(
              'CinemaScope config not found.\nPlease fill in assets/.env',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const CinemaScopeApp());
}

