import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cinema_colors.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUsers();
    });
  }

  Future<void> _changeRole(Profile user, String nextRole) async {
    final auth = context.read<AuthProvider>();
    final selfId = auth.profile?.id;

    if (selfId == user.id && nextRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot demote your own admin account while logged in.'),
          backgroundColor: CinemaColors.accent,
        ),
      );
      return;
    }

    final error = await auth.changeUserRole(userId: user.id, role: nextRole);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Role updated for ${user.email}'),
        backgroundColor: error == null ? CinemaColors.success : CinemaColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final users = auth.users;

    return Scaffold(
      backgroundColor: CinemaColors.bg,
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: auth.isUsersLoading ? null : auth.loadUsers,
          ),
        ],
      ),
      body: auth.isUsersLoading
          ? const Center(child: CircularProgressIndicator(color: CinemaColors.gold))
          : auth.error != null && users.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: CinemaColors.accentSoft),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : users.isEmpty
                  ? const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: CinemaColors.textMuted),
                      ),
                    )
                  : RefreshIndicator(
                      color: CinemaColors.gold,
                      onRefresh: auth.loadUsers,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final user = users[i];
                          final isSelf = user.id == auth.profile?.id;
                          return Container(
                            decoration: BoxDecoration(
                              color: CinemaColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: CinemaColors.divider),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: user.isAdmin
                                      ? CinemaColors.gold.withValues(alpha: 0.2)
                                      : CinemaColors.info.withValues(alpha: 0.2),
                                  child: Icon(
                                    user.isAdmin
                                        ? Icons.admin_panel_settings_rounded
                                        : Icons.person_rounded,
                                    size: 20,
                                    color: user.isAdmin
                                        ? CinemaColors.gold
                                        : CinemaColors.info,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: CinemaColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSelf ? 'This is your account' : 'User account',
                                        style: const TextStyle(
                                          color: CinemaColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _RoleDropdown(
                                  currentRole: user.role.toLowerCase(),
                                  disabled: auth.isRoleUpdating,
                                  onSelected: (role) => _changeRole(user, role),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String currentRole;
  final bool disabled;
  final ValueChanged<String> onSelected;

  const _RoleDropdown({
    required this.currentRole,
    required this.disabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: CinemaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole == 'admin' ? 'admin' : 'viewer',
          isDense: true,
          isExpanded: false,
          menuMaxHeight: 200,
          dropdownColor: CinemaColors.surface,
          style: const TextStyle(color: CinemaColors.textPrimary, fontSize: 13),
          iconEnabledColor: CinemaColors.textMuted,
          items: const [
            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: disabled
              ? null
              : (v) {
                  if (v != null) onSelected(v);
                },
        ),
      ),
    );
  }
}
