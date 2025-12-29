import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/route_log_model.dart';
import '../../provider/crags_provider.dart';
import '../../provider/logbook_provider.dart';
import '../../provider/routes_provider.dart';
import '../../provider/user_provider.dart';
import '../account/auth_panel.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
import '../common/route_log_dialog.dart';

/// 岩馆页面示例
class LogbookPage extends ConsumerWidget {
  const LogbookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final logs = ref.watch(userRouteLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showPageUpdateDialog(
                context: context,
                ref: ref,
                pageId: 'page:logbook',
                pageName: '个人记录',
                scopeKeys: const ['scope:logbook'],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: '个人记录', scopeKeys: const ['scope:logbook']);
            },
          ),
        ],
      ),
      body: user == null
          ? const AuthPanel()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (logs.isEmpty)
                  Text('暂无记录', style: Theme.of(context).textTheme.headlineSmall)
                else
                  ..._buildLogs(logs),
                CommentSection(targetKey: 'page:logbook'),
              ],
            ),
    );
  }

  List<Widget> _buildLogs(List<RouteLog> logs) {
    final widgets = <Widget>[];
    for (var i = 0; i < logs.length; i++) {
      if (i > 0) widgets.add(const Divider(height: 24));
      widgets.add(_LogbookRow(log: logs[i]));
    }
    return widgets;
  }
}

class _LogbookRow extends ConsumerWidget {
  final RouteLog log;

  const _LogbookRow({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeByIdProvider(log.routeId));
    if (route == null) {
      return ListTile(
        title: const Text('未知线路'),
        subtitle: Text(_formatInfo(log)),
      );
    }
    final data = ref.watch(cragDataProvider).asData?.value;
    final cragId = data?.cragIdForRoute(route);
    final crag = cragId == null ? null : ref.watch(cragByIdProvider(cragId));

    return ListTile(
      title: Text(route.name),
      subtitle: Text('${crag?.name ?? '未知岩场'} · ${_formatInfo(log)}'),
      trailing: Text(route.grade),
      onTap: () => showDialog(context: context, builder: (_) => RouteLogDialog(route: route, initialLog: log)),
    );
  }

  String _formatInfo(RouteLog log) {
    final date = _formatDateTime(log.dateTime);
    final belayer = log.belayerName == null ? '' : ' · 保护员 ${log.belayerName}';
    return '$date · ${log.climbType.label} · ${log.ascentType.label}$belayer';
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
  }
}
