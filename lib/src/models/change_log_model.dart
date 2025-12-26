enum ChangeTargetType { region, crag, wall, route, profile, page }

enum ChangeAction { create, update, delete, merge, pageUpdate }

extension ChangeActionLabel on ChangeAction {
  String get label {
    switch (this) {
      case ChangeAction.create:
        return '新增';
      case ChangeAction.update:
        return '编辑';
      case ChangeAction.delete:
        return '删除';
      case ChangeAction.merge:
        return '合并';
      case ChangeAction.pageUpdate:
        return '更新';
    }
  }
}

extension ChangeTargetLabel on ChangeTargetType {
  String get label {
    switch (this) {
      case ChangeTargetType.region:
        return '地区';
      case ChangeTargetType.crag:
        return '岩场';
      case ChangeTargetType.wall:
        return '岩壁/巨石';
      case ChangeTargetType.route:
        return '线路';
      case ChangeTargetType.profile:
        return '账号';
      case ChangeTargetType.page:
        return '页面';
    }
  }
}

class ChangeLogEntry {
  final String id;
  final String userId;
  final String userName;
  final ChangeTargetType targetType;
  final String targetId;
  final String targetName;
  final ChangeAction action;
  final DateTime timestamp;
  final String? description;
  final List<String> scopeKeys;

  const ChangeLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.action,
    required this.timestamp,
    this.description,
    this.scopeKeys = const [],
  });

  String summary() {
    final detail = description == null || description!.trim().isEmpty ? '' : ' · ${description!.trim()}';
    return '${action.label}${targetType.label} $targetName$detail';
  }
}
