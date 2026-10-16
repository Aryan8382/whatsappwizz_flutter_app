import 'package:flutter/material.dart';
import '../../../core/services/repositories/users_api_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/modal_sheet.dart';
import '../../../shared/widgets/status_badge.dart';
import 'widgets/add_user_sheet.dart';


/// Matches DB Table: `users`
class _UserRecord {
  final int id;
  final int organizationId;
  final int roleId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String status;
  final DateTime lastLogin;
  final DateTime createdAt;

  const _UserRecord({
    required this.id,
    required this.organizationId,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get roleLabel {
    switch (roleId) {
      case 1:
      case 6:
        return 'Super Admin';
      case 2:
      case 7:
        return 'Org Admin';
      case 3:
      case 8:
        return 'Supervisor';
      case 4:
      case 9:
        return 'Agent';
      case 5:
      case 10:
        return 'Reseller';
      default:
        return 'Agent';
    }
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _usersRepo = UsersApiRepository();
  bool _isLoading = false;

  final List<_UserRecord> _team = [];

  String _selectedStatusFilter = 'All';
  final List<String> _statusFilters = ['All', 'Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final list = await _usersRepo.getUsers();
      if (list.isNotEmpty) {
        _team.clear();
        for (final u in list) {
          _team.add(_UserRecord(
            id: int.tryParse(u.id.toString()) ?? 0,
            organizationId: int.tryParse(u.organizationId.toString()) ?? 2,
            roleId: int.tryParse(u.roleId.toString()) ?? 4,
            firstName: u.firstName,
            lastName: u.lastName,
            email: u.email,
            mobile: u.mobile ?? '',
            status: u.status,
            lastLogin: u.lastLogin ?? DateTime.now(),
            createdAt: u.createdAt ?? DateTime.now(),
          ));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showUserDetail(_UserRecord user) {
    ModalSheet.show(
      context: context,
      title: 'User DB Record',
      subtitle: 'Table: users • ID #${user.id}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.g50,
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: AppColors.g200),
            ),
            child: Row(
              children: [
                AppAvatar(name: user.fullName, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: AppTypography.titleLarge.copyWith(fontSize: 17)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            user.roleLabel,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.g700),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: user.status, label: user.status.toUpperCase()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _dbRow('id', '#${user.id}'),
          _dbRow('organization_id', '#${user.organizationId}'),
          _dbRow('role_id', '#${user.roleId} → ${user.roleLabel}'),
          _dbRow('first_name', user.firstName),
          _dbRow('last_name', user.lastName),
          _dbRow('email', user.email, copyable: true),
          _dbRow('mobile', user.mobile),
          _dbRow('password_hash', '••••••••••••••••', hint: 'bcrypt (hidden)'),
          _dbRow('avatar', 'NULL', hint: 'No avatar set'),
          _dbRow('status', user.status),
          _dbRow('last_login', _fmt(user.lastLogin)),
          _dbRow('created_at', _fmt(user.createdAt)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    AddUserSheet.show(
                      context,
                      initialValue: {
                        'first_name': user.firstName,
                        'last_name': user.lastName,
                        'email': user.email,
                        'mobile': user.mobile,
                        'status': user.status,
                        'role_id': user.roleId,
                      },
                      onSave: (data) async {
                        try {
                          await _usersRepo.updateUser(user.id, data);
                          ToastService.success('User updated successfully');
                          _loadUsers();
                        } catch (e) {
                          ToastService.error('Failed to update: $e');
                        }
                      },
                    );
                  },
                  icon: const Icon(LucideIcons.edit2, size: 15),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.statusRedText),
                tooltip: 'Delete User',
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context: context,
                    title: 'Delete User',
                    message: 'Are you sure you want to remove ${user.fullName} (${user.email})?',
                    confirmLabel: 'Delete',
                  );
                  if (ok == true) {
                    Navigator.pop(context);
                    try {
                      await _usersRepo.deleteUser(user.id);
                      ToastService.success('User removed');
                      _loadUsers();
                    } catch (e) {
                      ToastService.error('Failed to delete: $e');
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showResetPasswordDialog(user);
                  },
                  icon: const Icon(LucideIcons.key, size: 15),
                  label: const Text('Reset Pwd'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.g600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(_UserRecord user) {
    final pwdController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.border2xl),
        title: Text('Reset Password for ${user.firstName}', style: AppTypography.titleMedium),
        content: TextField(
          controller: pwdController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter at least 6 characters',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPwd = pwdController.text.trim();
              if (newPwd.length < 6) {
                ToastService.error('Password must be at least 6 characters');
                return;
              }
              Navigator.pop(ctx);
              try {
                await _usersRepo.updateUser(user.id, {'password': newPwd});
                ToastService.success('Password updated successfully');
              } catch (e) {
                ToastService.error('Failed to update password: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.g600),
            child: const Text('Save Password'),
          ),
        ],
      ),
    );
  }


  Widget _dbRow(String col, String val, {bool copyable = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              col,
              style: const TextStyle(
                fontSize: 11.5,
                fontFamily: 'monospace',
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    val,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(width: 4),
                  Text(hint, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                ],
                if (copyable) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ToastService.info('Copied $val'),
                    child: const Icon(LucideIcons.copy, size: 13, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final filtered = _team.where((u) {
      if (_selectedStatusFilter == 'Active') return u.status == 'active';
      if (_selectedStatusFilter == 'Inactive') return u.status == 'inactive';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Team & Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                // DB Stats Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.g50,
                    borderRadius: AppRadii.borderFull,
                    border: Border.all(color: AppColors.g200),
                  ),
                  child: Text(
                    '${_team.length} users in DB',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.g800),
                  ),
                ),
                const SizedBox(width: 8),
                ..._statusFilters.map((f) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatusFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _selectedStatusFilter == f ? AppColors.g600 : Colors.white,
                        borderRadius: AppRadii.borderFull,
                        border: Border.all(
                          color: _selectedStatusFilter == f ? AppColors.g600 : AppColors.g200,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _selectedStatusFilter == f ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final u = filtered[index];
          final isActive = u.status == 'active';
          final isOnline = u.lastLogin.isAfter(DateTime.now().subtract(const Duration(minutes: 30)));

          return FadeSlideIn.staggered(
            index: index,
            child: InkWell(
              onTap: () => _showUserDetail(u),
              borderRadius: AppRadii.border2xl,
              child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.border2xl,
                border: Border.all(color: const Color(0x3322C55E)),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      AppAvatar(name: u.fullName, radius: 22),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.waGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.fullName, style: AppTypography.titleMedium.copyWith(fontSize: 14.5)),
                        const SizedBox(height: 1),
                        Text(u.email, style: AppTypography.bodySmall),
                        const SizedBox(height: 3),
                        Text(
                          'Last login: ${_fmt(u.lastLogin)}',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(status: u.roleLabel.toLowerCase().replaceAll(' ', '_'), label: u.roleLabel),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.statusGreenBg : Colors.grey[100],
                          borderRadius: AppRadii.borderFull,
                        ),
                        child: Text(
                          isActive ? '● Active' : '○ Inactive',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColors.statusGreenText : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.userPlus, size: 20),
          label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddUserSheet.show(
              context,
              onSave: (data) async {
                try {
                  await _usersRepo.createUser(data);
                  ToastService.success('User created successfully');
                  _loadUsers();
                } catch (e) {
                  ToastService.error('Failed to create user: $e');
                }
              },
            );
          },

        ),
      ),
    );
  }
}
