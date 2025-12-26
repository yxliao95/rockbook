import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/user_provider.dart';

class AuthPanel extends ConsumerStatefulWidget {
  const AuthPanel({super.key});

  @override
  ConsumerState<AuthPanel> createState() => _AuthPanelState();
}

class _AuthPanelState extends ConsumerState<AuthPanel> {
  final TextEditingController _passwordController = TextEditingController(text: '123456');
  final TextEditingController _registerNicknameController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  String? _selectedNickname;

  @override
  void dispose() {
    _passwordController.dispose();
    _registerNicknameController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(allUsersProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('登录/注册', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('快捷登录', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedNickname,
                  decoration: const InputDecoration(labelText: '选择测试账号', border: OutlineInputBorder()),
                  items: users
                      .map((user) => DropdownMenuItem(value: user.nickname, child: Text(user.nickname)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedNickname = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(onPressed: () => _handleLogin(context), child: const Text('登录')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('注册新账号', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _registerNicknameController,
                  decoration: const InputDecoration(labelText: '昵称', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _registerPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(onPressed: () => _handleRegister(context), child: const Text('注册并登录')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin(BuildContext context) {
    final nickname = _selectedNickname;
    if (nickname == null) {
      _showSnack(context, '请选择账号');
      return;
    }
    final success = ref
        .read(userSessionProvider.notifier)
        .login(nickname: nickname, password: _passwordController.text.trim());
    if (!success) {
      _showSnack(context, '登录失败，请检查密码');
    }
  }

  void _handleRegister(BuildContext context) {
    final nickname = _registerNicknameController.text.trim();
    final password = _registerPasswordController.text.trim();
    if (nickname.isEmpty || password.isEmpty) {
      _showSnack(context, '请填写昵称和密码');
      return;
    }
    final success = ref.read(userSessionProvider.notifier).register(nickname: nickname, password: password);
    if (!success) {
      _showSnack(context, '昵称已存在');
    } else {
      _registerNicknameController.clear();
      _registerPasswordController.clear();
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
