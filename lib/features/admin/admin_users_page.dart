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

  Future<void> _showCreateDialog() async {
    final auth = context.read<AuthProvider>();
    final emailCtl = TextEditingController();
    final passwordCtl = TextEditingController();
    String role = 'viewer';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CinemaColors.card,
          title: const Text('Create User Profile', style: TextStyle(color: CinemaColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InputField(controller: emailCtl, label: 'Email'),
                const SizedBox(height: 10),
                _InputField(
                  controller: passwordCtl,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                _RoleField(
                  value: role,
                  onChanged: (v) => setState(() => role = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    if (emailCtl.text.trim().isEmpty || passwordCtl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required'), backgroundColor: CinemaColors.accent),
      );
      return;
    }

    final error = await auth.createUserWithPassword(
      email: emailCtl.text,
      password: passwordCtl.text,
      role: role,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'User profile created'),
        backgroundColor: error == null ? CinemaColors.success : CinemaColors.accent,
      ),
    );
  }

  Future<void> _showEditDialog(Profile user) async {
    final auth = context.read<AuthProvider>();
    final emailCtl = TextEditingController(text: user.email);
    String role = user.role.toLowerCase() == 'admin' ? 'admin' : 'viewer';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CinemaColors.card,
          title: const Text('Edit User', style: TextStyle(color: CinemaColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InputField(controller: emailCtl, label: 'Email'),
                const SizedBox(height: 10),
                _RoleField(
                  value: role,
                  onChanged: (v) => setState(() => role = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final selfId = auth.profile?.id;
    if (selfId == user.id && role != 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot demote your own admin account while logged in.'),
          backgroundColor: CinemaColors.accent,
        ),
      );
      return;
    }

    final error = await auth.updateUserProfile(
      userId: user.id,
      email: emailCtl.text,
      role: role,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'User updated'),
        backgroundColor: error == null ? CinemaColors.success : CinemaColors.accent,
      ),
    );
  }

  Future<void> _deleteUser(Profile user) async {
    final auth = context.read<AuthProvider>();
    if (user.id == auth.profile?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own account while logged in.'),
          backgroundColor: CinemaColors.accent,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemaColors.card,
        title: const Text('Delete User', style: TextStyle(color: CinemaColors.textPrimary)),
        content: Text(
          'Delete profile for ${user.email}?',
          style: const TextStyle(color: CinemaColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CinemaColors.accent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final error = await auth.deleteUserProfile(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'User profile deleted'),
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
            tooltip: 'Create profile',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: auth.isUsersLoading ? null : _showCreateDialog,
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
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 430;
                                    if (compact) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
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
                                              const SizedBox(width: 12),
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
                                                      isSelf
                                                          ? 'This is your account'
                                                          : 'User account',
                                                      style: const TextStyle(
                                                        color: CinemaColors.textMuted,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          _RoleBadge(role: user.role),
                                        ],
                                      );
                                    }
                                    return Row(
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
                                                isSelf
                                                    ? 'This is your account'
                                                    : 'User account',
                                                style: const TextStyle(
                                                  color: CinemaColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        _RoleBadge(role: user.role),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showEditDialog(user),
                                      icon: const Icon(Icons.edit_rounded, size: 16),
                                      label: const Text('Edit'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _deleteUser(user),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: CinemaColors.accent),
                                      label: const Text('Delete', style: TextStyle(color: CinemaColors.accent)),
                                    ),
                                  ],
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.label,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: CinemaColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: CinemaColors.textMuted),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: CinemaColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: CinemaColors.gold),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CinemaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CinemaColors.divider),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Viewer',
        style: const TextStyle(
          color: CinemaColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoleField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RoleField({required this.value, required this.onChanged});

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
          value: value,
          dropdownColor: CinemaColors.surface,
          style: const TextStyle(color: CinemaColors.textPrimary),
          iconEnabledColor: CinemaColors.textMuted,
          items: const [
            DropdownMenuItem(value: 'viewer', child: Text('Role: Viewer')),
            DropdownMenuItem(value: 'admin', child: Text('Role: Admin')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

