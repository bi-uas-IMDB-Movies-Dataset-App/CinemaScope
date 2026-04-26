import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../admin/admin_movies_page.dart';
import '../admin/admin_users_page.dart';
import '../dashboard/dashboard_page.dart';
import '../explore/explore_page.dart';
import '../movies/movies_page.dart';
import '../settings/settings_page.dart';
import '../watchlist/watchlist_page.dart';

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
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Dashboard'),
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
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.edit_note_rounded, label: 'CRUD Movies'),
    _NavItem(icon: Icons.manage_accounts_rounded, label: 'Manage Users'),
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
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration:
              const BoxDecoration(border: Border(top: BorderSide(color: CinemaColors.divider))),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: onChanged,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 11,
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
      body: Row(
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
                        Icon(Icons.movie_filter_rounded,
                            color: CinemaColors.gold, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'CinemaScope',
                          style: TextStyle(
                              color: CinemaColors.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  const Icon(Icons.movie_filter_rounded,
                      color: CinemaColors.gold, size: 28),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
