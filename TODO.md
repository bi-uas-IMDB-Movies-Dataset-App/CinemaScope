# Fix Plan for CinemaScope Errors

## Information Gathered
- Flutter app with admin dashboard, movie browsing, watchlist, and explore features
- Uses Provider for state management, Supabase for backend, fl_chart for charts
- Key issues: depth error on admin users page, RenderFlex overflow (12px bottom), cramped bars/UI, release APK safety

## Plan

### 1. `lib/features/admin/admin_users_page.dart`
- Fix `_RoleDropdown` depth error by adding `isDense: true`, `menuMaxHeight`, and proper constraints
- Increase list item padding to prevent cramped bars
- Add bottom safe padding to ListView

### 2. `lib/widgets/movie_tile.dart` (MovieDetailPage)
- Fix `_RatingRow` horizontal overflow with `SingleChildScrollView`
- Add bottom padding in `SliverToBoxAdapter` to prevent 12px bottom overflow
- Fix `_StatsGrid` to prevent overflow

### 3. `lib/features/explore/explore_page.dart`
- Fix `_QuickStats` Row overflow on small screens using `SingleChildScrollView`
- Increase bar spacing in `_GenreDistribution` and `_DecadeChart`
- Add proper bottom padding

### 4. `lib/features/dashboard/dashboard_page.dart`
- Fix `_RatingDistributionChart` bottom labels mismatch (only 3 labels for 5 entries)
- Fix `_GenrePieChart` overflow on narrow screens with `LayoutBuilder`/`Wrap`
- Fix `_KpiRow` aspect ratio to prevent text overflow
- Increase spacing between chart bars

### 5. `lib/features/home/home_page.dart`
- Wrap `_BottomNavLayout` BottomNavigationBar in `SafeArea` to prevent bottom overflow
- Increase `_SidebarTile` padding to prevent cramped feel
- Ensure proper bottom nav spacing

### 6. `lib/theme/cinema_theme.dart`
- Add explicit bottom nav icon/label themes for better spacing
- Ensure selected/unselected font sizes don't cause overflow

### 7. `android/app/build.gradle.kts`
- Add minification/shrinking for release build
- Add ProGuard rules file reference
- Add release signing config placeholder

### 8. `android/app/src/main/AndroidManifest.xml`
- Add `android:enableOnBackInvokedCallback="true"` for Android 13+

## Dependent Files
- All files listed above are independent of each other except theme changes affect all pages

## Followup Steps
- Run `flutter build apk --release` to verify release build compiles
- Test on different screen sizes to verify overflow fixes

