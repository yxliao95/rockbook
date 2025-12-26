import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/change_log_model.dart';

class ChangeLogNotifier extends Notifier<List<ChangeLogEntry>> {
  @override
  List<ChangeLogEntry> build() {
    return _seedLogs();
  }

  void addEntry(ChangeLogEntry entry) {
    state = [...state, entry];
  }

  List<ChangeLogEntry> _seedLogs() {
    final now = DateTime.now();
    return [
      ChangeLogEntry(
        id: 'log1',
        userId: 'u1',
        userName: '阿岩',
        targetType: ChangeTargetType.page,
        targetId: 'page:routes',
        targetName: '线路',
        action: ChangeAction.pageUpdate,
        timestamp: now.subtract(const Duration(days: 1)),
        description: '补充了线路难度标签',
        scopeKeys: const ['scope:routes'],
      ),
      ChangeLogEntry(
        id: 'log2',
        userId: 'u2',
        userName: '木木',
        targetType: ChangeTargetType.crag,
        targetId: 'c1',
        targetName: '老鹰嘴',
        action: ChangeAction.update,
        timestamp: now.subtract(const Duration(hours: 6)),
        description: '更新了接近方式',
        scopeKeys: const ['scope:crags'],
      ),
    ];
  }
}

final changeLogProvider = NotifierProvider<ChangeLogNotifier, List<ChangeLogEntry>>(ChangeLogNotifier.new);
