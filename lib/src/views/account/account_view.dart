import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/change_log_model.dart';
import '../../models/user_model.dart';
import '../../provider/change_log_provider.dart';
import '../../provider/user_provider.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
import 'auth_panel.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _armSpanController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _editingUserId;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    _armSpanController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('账号'),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showPageUpdateDialog(
                context: context,
                ref: ref,
                pageId: 'page:account',
                pageName: '账号',
                scopeKeys: const ['scope:account'],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: '账号', scopeKeys: const ['scope:account']);
            },
          ),
        ],
      ),
      body: isLoggedIn ? _buildProfile(context, user) : const AuthPanel(),
    );
  }

  Widget _buildProfile(BuildContext context, AppUser user) {
    _syncControllers(user);
    final logs =
        ref
            .watch(changeLogProvider)
            .where(
              (log) =>
                  log.userId == user.id &&
                  (log.targetType == ChangeTargetType.region ||
                      log.targetType == ChangeTargetType.crag ||
                      log.targetType == ChangeTargetType.wall ||
                      log.targetType == ChangeTargetType.route),
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('个人信息', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: '昵称', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        decoration: const InputDecoration(labelText: '身高(cm)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _armSpanController,
                        decoration: const InputDecoration(labelText: '臂展(cm)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: '体重(kg)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => ref.read(userSessionProvider.notifier).logout(),
                      child: const Text('退出登录'),
                    ),
                    FilledButton(onPressed: () => _saveProfile(context, user), child: const Text('保存')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('我的路书编辑记录', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (logs.isEmpty)
          const Text('暂无编辑记录')
        else
          ...logs
              .take(10)
              .map(
                (log) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(log.summary()),
                  subtitle: Text(_formatDateTime(log.timestamp)),
                ),
              ),
        CommentSection(targetKey: 'page:account'),
      ],
    );
  }

  void _syncControllers(AppUser user) {
    if (_editingUserId == user.id) return;
    _editingUserId = user.id;
    _nicknameController.text = user.nickname;
    _passwordController.text = user.password;
    _heightController.text = user.heightCm?.toString() ?? '';
    _armSpanController.text = user.armSpanCm?.toString() ?? '';
    _weightController.text = user.weightKg?.toString() ?? '';
  }

  void _saveProfile(BuildContext context, AppUser user) {
    final height = int.tryParse(_heightController.text.trim());
    final armSpan = int.tryParse(_armSpanController.text.trim());
    final weight = int.tryParse(_weightController.text.trim());
    final updated = user.copyWith(
      nickname: _nicknameController.text.trim().isEmpty ? user.nickname : _nicknameController.text.trim(),
      password: _passwordController.text.trim().isEmpty ? user.password : _passwordController.text.trim(),
      heightCm: height,
      armSpanCm: armSpan,
      weightKg: weight,
    );
    ref.read(userSessionProvider.notifier).updateProfile(updated);
    ref
        .read(changeLogProvider.notifier)
        .addEntry(
          ChangeLogEntry(
            id: 'log-${DateTime.now().microsecondsSinceEpoch}',
            userId: user.id,
            userName: user.nickname,
            targetType: ChangeTargetType.profile,
            targetId: user.id,
            targetName: user.nickname,
            action: ChangeAction.update,
            timestamp: DateTime.now(),
            description: '更新个人资料',
            scopeKeys: const ['scope:account'],
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
  }
}
