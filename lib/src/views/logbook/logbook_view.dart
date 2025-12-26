import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/route_log_model.dart';
import '../../provider/crags_provider.dart';
import '../../provider/logbook_provider.dart';
import '../../provider/routes_provider.dart';
import '../common/route_log_dialog.dart';

/// 岩馆页面示例
class LogbookPage extends ConsumerWidget {
  const LogbookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(routeLogsProvider);

    if (logs.isEmpty) {
      return Center(child: Text('暂无记录', style: Theme.of(context).textTheme.headlineMedium));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _LogbookRow(log: log);
      },
    );
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
    final crag = ref.watch(cragByIdProvider(route.cragId));

    return ListTile(
      title: Text(route.name),
      subtitle: Text('${crag?.name ?? '未知岩场'} · ${_formatInfo(log)}'),
      trailing: Text(route.grade),
      onTap: () => showDialog(context: context, builder: (_) => RouteLogDialog(route: route, initialLog: log)),
    );
  }

  String _formatInfo(RouteLog log) {
    final date = _formatDateTime(log.dateTime);
    return '$date · ${log.climbType.label} · ${log.ascentType.label}';
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
  }
}
