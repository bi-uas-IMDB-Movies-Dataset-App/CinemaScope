# CinemaScope

A Flutter app to discover and explore top movies inspired by IMDb.

## Features

- Movies browsing, search, and genre filters
- Explore + Dashboard analytics (BI/OLAP style)
- Watchlist per user
- Viewer personal rating and metascore
- Admin movie CRUD
- Admin user management
- Supabase Auth + PostgreSQL backend

## Setup

1. Run SQL in Supabase:
   - `cinemascope_supabase.sql`
   - optional policy updates in `supabase/run_all.sql`
2. Configure env:
   - copy `.env_example` to `assets/.env`
   - fill `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Install and run:
   - `flutter pub get`
   - `flutter run`

## Tech Stack

- Flutter + Dart
- Supabase
- Provider
- fl_chart
