import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/app_state_provider.dart';
import '../../provider/user_provider.dart';
import 'app_tabs.dart';

Future<void> showLoginRequiredDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('需要登录'),
        content: const Text('登录后才能使用该功能。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).setTabTo(kTabIndexAccount);
              Navigator.of(context).pop();
            },
            child: const Text('去登录'),
          ),
        ],
      );
    },
  );
}

bool requireLogin(BuildContext context, WidgetRef ref) {
  final loggedIn = ref.read(isLoggedInProvider);
  if (!loggedIn) {
    showLoginRequiredDialog(context, ref);
    return false;
  }
  return true;
}
