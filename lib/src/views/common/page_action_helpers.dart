import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/change_log_model.dart';
import '../../provider/change_log_provider.dart';
import '../../provider/user_provider.dart';

Future<void> showPageUpdateDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String pageId,
  required String pageName,
  List<String> scopeKeys = const [],
}) async {
  final controller = TextEditingController();
  final user = ref.read(currentUserProvider);
  await showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text('更新$pageName'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '更新说明', border: OutlineInputBorder()),
          minLines: 1,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (user != null) {
                ref
                    .read(changeLogProvider.notifier)
                    .addEntry(
                      ChangeLogEntry(
                        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
                        userId: user.id,
                        userName: user.nickname,
                        targetType: ChangeTargetType.page,
                        targetId: pageId,
                        targetName: pageName,
                        action: ChangeAction.pageUpdate,
                        timestamp: DateTime.now(),
                        description: controller.text.trim().isEmpty ? '更新页面信息' : controller.text.trim(),
                        scopeKeys: scopeKeys,
                      ),
                    );
              }
              Navigator.of(context).pop();
            },
            child: const Text('提交'),
          ),
        ],
      );
    },
  );
}

Future<void> showHistoryDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  List<String> scopeKeys = const [],
}) async {
  final logs =
      ref
          .read(changeLogProvider)
          .where((entry) => scopeKeys.isEmpty || entry.scopeKeys.any(scopeKeys.contains))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  await showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text('$title · 历史记录'),
        content: SizedBox(
          width: double.maxFinite,
          child: logs.isEmpty
              ? const Text('暂无历史记录')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (_, index) {
                    final log = logs[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.summary(), style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${log.userName} · ${_formatDateTime(log.timestamp)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭'))],
      );
    },
  );
}

String _formatDateTime(DateTime value) {
  final paddedMonth = value.month.toString().padLeft(2, '0');
  final paddedDay = value.day.toString().padLeft(2, '0');
  final paddedHour = value.hour.toString().padLeft(2, '0');
  final paddedMinute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
}
