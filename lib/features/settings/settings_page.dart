import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cinema_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(title: const Text('CinemaScope • Profile')),
      body: RefreshIndicator(
        color: CinemaColors.gold,
        onRefresh: () => context.read<AuthProvider>().loadProfile(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Profile card
          CinemaCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CinemaColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: CinemaColors.gold.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: CinemaColors.gold,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.email ?? '-',
                        style: const TextStyle(
                          color: CinemaColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: CinemaColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: CinemaColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          (profile?.role ?? 'viewer').toUpperCase(),
                          style: const TextStyle(
                            color: CinemaColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About section
          const _SectionTitle('About CinemaScope'),
          const SizedBox(height: 10),
          const CinemaCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.movie_filter_rounded,
                  label: 'Data Source',
                  value: 'IMDb Top 1000',
                ),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(
                  icon: Icons.storage_rounded,
                  label: 'Database',
                  value: 'Supabase (PostgreSQL)',
                ),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(
                  icon: Icons.code_rounded,
                  label: 'Built With',
                  value: 'Flutter + Dart',
                ),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: '1.0.0',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dataset stats
          const _SectionTitle('Dataset Overview'),
          const SizedBox(height: 10),
          const CinemaCard(
            child: Column(
              children: [
                _InfoRow(
                    icon: Icons.movie_rounded, label: 'Total Movies', value: '1,000'),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(
                    icon: Icons.person_rounded, label: 'Directors', value: '548'),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(icon: Icons.category_rounded, label: 'Genres', value: '21'),
                Divider(color: CinemaColors.divider, height: 20),
                _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Years Covered',
                    value: '1920 - 2020'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Sign out
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: CinemaColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
                            style:
                                TextStyle(color: CinemaColors.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  context.read<AuthProvider>().logout();
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CinemaColors.accentSoft,
                side: const BorderSide(color: CinemaColors.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CinemaColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: CinemaColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: CinemaColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: CinemaColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
      ],
    );
  }
}

