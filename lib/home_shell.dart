import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinemascope/core/constants/cinema_colors.dart';
import 'package:cinemascope/features/admin/admin_movies_page.dart';
import 'package:cinemascope/features/admin/admin_users_page.dart';
import 'package:cinemascope/features/dashboard/dashboard_page.dart';
import 'package:cinemascope/features/explore/explore_page.dart';
import 'package:cinemascope/features/settings/settings_page.dart';
import 'package:cinemascope/features/watchlist/watchlist_page.dart';
import 'package:cinemascope/providers/movie_provider.dart';
import 'package:cinemascope/providers/auth_provider.dart';
import 'package:cinemascope/providers/watchlist_provider.dart';
import 'package:cinemascope/widgets/genre_chip.dart';
import 'package:cinemascope/widgets/movie_tile.dart';
import 'package:cinemascope/widgets/shimmer_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().profile?.isAdmin ?? false;
    return isAdmin ? const AdminHomePage() : const UserHomePage();
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _index = 0;

  static const _pages = [
    MoviesPage(),
    ExplorePage(),
    WatchlistPage(),
    DashboardPage(),
    SettingsPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.movie_rounded, label: 'Movies'),
    _NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    _NavItem(icon: Icons.bookmark_rounded, label: 'Watchlist'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Insights'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().loadIds();
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CinemaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(color: CinemaColors.textPrimary)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: CinemaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: CinemaColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final watchlistCount = context.watch<WatchlistProvider>().ids.length;

    if (width >= 700) {
      return _SidebarLayout(
        index: _index,
        pages: _pages,
        navItems: _navItems,
        badgeTabIndex: 2,
        badgeCount: watchlistCount,
        onChanged: (i) => setState(() => _index = i),
        onLogout: _confirmLogout,
      );
    }

    return _BottomNavLayout(
      index: _index,
      pages: _pages,
      navItems: _navItems,
      badgeTabIndex: 2,
      badgeCount: watchlistCount,
      onChanged: (i) => setState(() => _index = i),
      onLogout: _confirmLogout,
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    AdminMoviesPage(),
    AdminUsersPage(),
    ExplorePage(),
    SettingsPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Insights'),
    _NavItem(icon: Icons.edit_note_rounded, label: 'Movies'),
    _NavItem(icon: Icons.manage_accounts_rounded, label: 'Users'),
    _NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Profile'),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CinemaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(color: CinemaColors.textPrimary)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: CinemaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: CinemaColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 700) {
      return _SidebarLayout(
        index: _index,
        pages: _pages,
        navItems: _navItems,
        badgeTabIndex: null,
        badgeCount: 0,
        onChanged: (i) => setState(() => _index = i),
        onLogout: _confirmLogout,
      );
    }
    return _BottomNavLayout(
      index: _index,
      pages: _pages,
      navItems: _navItems,
      badgeTabIndex: null,
      badgeCount: 0,
      onChanged: (i) => setState(() => _index = i),
      onLogout: _confirmLogout,
    );
  }
}

class _BottomNavLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final int? badgeTabIndex;
  final int badgeCount;
  final ValueChanged<int> onChanged;
  final VoidCallback onLogout;

  const _BottomNavLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.badgeTabIndex,
    required this.badgeCount,
    required this.onChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuroraBackground(),
          IndexedStack(index: index, children: pages),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Container(
          decoration: BoxDecoration(
            color: CinemaColors.glass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CinemaColors.divider),
            boxShadow: [
              BoxShadow(
                color: CinemaColors.cyan.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: onChanged,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 10.5,
            unselectedFontSize: 10,
            iconSize: 22,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: navItems.asMap().entries.map((e) {
              final showBadge = badgeTabIndex == e.key && badgeCount > 0;
              if (showBadge) {
                return BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('$badgeCount'),
                    backgroundColor: CinemaColors.gold,
                    textColor: Colors.black,
                    child: Icon(navItems[e.key].icon),
                  ),
                  label: navItems[e.key].label,
                );
              }
              return BottomNavigationBarItem(
                icon: Icon(navItems[e.key].icon),
                label: navItems[e.key].label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SidebarLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final int? badgeTabIndex;
  final int badgeCount;
  final ValueChanged<int> onChanged;
  final VoidCallback onLogout;

  const _SidebarLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.badgeTabIndex,
    required this.badgeCount,
    required this.onChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().profile?.email ?? '';
    final extended = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      body: SafeArea(
        child: Row(
        children: [
          Container(
            width: extended ? 220 : 72,
            color: CinemaColors.surface,
            child: Column(
              children: [
                const SizedBox(height: 24),
                if (extended)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: CinemaColors.cyan, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'CinemaScope',
                          style: TextStyle(
                              color: CinemaColors.goldLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  const Icon(Icons.auto_awesome_rounded,
                      color: CinemaColors.cyan, size: 24),
                const SizedBox(height: 28),
                const Divider(color: CinemaColors.divider, height: 1),
                const SizedBox(height: 12),
                ...navItems.asMap().entries.map((e) {
                  final isSelected = index == e.key;
                  final showBadge = badgeTabIndex == e.key && badgeCount > 0;
                  return _SidebarTile(
                    icon: e.value.icon,
                    label: e.value.label,
                    selected: isSelected,
                    extended: extended,
                    badgeCount: showBadge ? badgeCount : 0,
                    onTap: () => onChanged(e.key),
                  );
                }),
                const Spacer(),
                const Divider(color: CinemaColors.divider, height: 1),
                if (extended)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: CinemaColors.gold,
                          child: Icon(Icons.person, size: 18, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(email,
                              style: const TextStyle(
                                  color: CinemaColors.textMuted, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: CinemaColors.textMuted, size: 18),
                          onPressed: onLogout,
                        ),
                      ],
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: CinemaColors.textMuted),
                    onPressed: onLogout,
                    tooltip: 'Sign Out',
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: CinemaColors.divider),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final int badgeCount;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = badgeCount > 0
        ? Badge(
            label: Text('$badgeCount'),
            backgroundColor: CinemaColors.gold,
            textColor: Colors.black,
            child: Icon(icon,
                color: selected ? CinemaColors.gold : CinemaColors.textMuted,
                size: 20),
          )
        : Icon(icon,
            color: selected ? CinemaColors.gold : CinemaColors.textMuted,
            size: 20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 14 : 0,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? CinemaColors.gold.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: extended
              ? Row(children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Text(label,
                      style: TextStyle(
                        color: selected ? CinemaColors.gold : CinemaColors.textMuted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      )),
                ])
              : Center(child: iconWidget),
        ),
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CinemaColors.bg,
            CinemaColors.surface.withValues(alpha: 0.92),
            const Color(0xFF0A0E1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _GlowOrb(
              color: CinemaColors.cyan.withValues(alpha: 0.2),
              size: 220,
            ),
          ),
          Positioned(
            top: 120,
            right: -60,
            child: _GlowOrb(
              color: CinemaColors.accent.withValues(alpha: 0.18),
              size: 200,
            ),
          ),
          Positioned(
            bottom: -90,
            left: 60,
            child: _GlowOrb(
              color: CinemaColors.teal.withValues(alpha: 0.18),
              size: 240,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});
  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MovieProvider>();
      if (p.topMovies.isEmpty) p.loadTopMovies();
      if (p.genres.isEmpty) p.loadGenres();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchActive = !_searchActive);
    if (!_searchActive) {
      _searchCtrl.clear();
      context.read<MovieProvider>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MovieProvider>();
    final isSearchMode = _searchActive && _searchCtrl.text.isNotEmpty;
    final movies = isSearchMode ? prov.searchResults : prov.topMovies;

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: _searchActive
            ? Row(
                children: [
                  const Text('CinemaScope', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: CinemaColors.textPrimary),
                      cursorColor: CinemaColors.gold,
                      decoration: const InputDecoration(
                        hintText: 'Search movies...',
                        hintStyle: TextStyle(color: CinemaColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (q) => prov.search(q),
                    ),
                  ),
                ],
              )
            : const Row(
                children: [
                  Icon(Icons.theaters_rounded, color: CinemaColors.cyan, size: 18),
                  SizedBox(width: 8),
                  Text('CinemaScope • Movies'),
                  SizedBox(width: 8),
                  Icon(Icons.auto_awesome_rounded, color: CinemaColors.gold, size: 16),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close : Icons.search_rounded,
              color: CinemaColors.textSecondary,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_searchActive)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: _VisualTicker(),
            ),
          if (!_searchActive && prov.genres.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GenreChip(
                      label: 'All',
                      selected: prov.selectedGenre == null,
                      onTap: () => prov.filterByGenre(null),
                    ),
                  ),
                  ...prov.genres.map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GenreChip(
                          label: g,
                          selected: prov.selectedGenre == g,
                          onTap: () => prov.filterByGenre(g),
                        ),
                      )),
                ],
              ),
            ),
          Expanded(
            child: prov.isLoading
                ? const ShimmerMovieList()
                : prov.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: CinemaColors.accent, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load: ${prov.error}',
                              style: const TextStyle(color: CinemaColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: prov.loadTopMovies,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : movies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.movie_outlined,
                                    color: CinemaColors.textMuted, size: 56),
                                const SizedBox(height: 12),
                                Text(
                                  isSearchMode
                                      ? 'No results for "${_searchCtrl.text}"'
                                      : 'No movies found',
                                  style: const TextStyle(color: CinemaColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: CinemaColors.gold,
                            onRefresh: prov.loadTopMovies,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: movies.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: MovieTile(
                                  movie: movies[i],
                                  rank: isSearchMode ? null : i + 1,
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _VisualTicker extends StatelessWidget {
  const _VisualTicker();

  @override
  Widget build(BuildContext context) {
    Widget pill(IconData icon, String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CinemaColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: CinemaColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          pill(Icons.local_fire_department_rounded, 'Trending', CinemaColors.accent),
          const SizedBox(width: 8),
          pill(Icons.auto_awesome_rounded, 'Editor Pick', CinemaColors.gold),
          const SizedBox(width: 8),
          pill(Icons.bolt_rounded, 'Fast Watch', CinemaColors.cyan),
          const SizedBox(width: 8),
          pill(Icons.theaters_rounded, 'Cinema Mood', CinemaColors.teal),
        ],
      ),
    );
  }
}

