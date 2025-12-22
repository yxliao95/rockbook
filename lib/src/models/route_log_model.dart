enum ClimbType {
  lead,
  topRope,
  bouldering,
}

enum AscentType {
  onsight,
  flash,
  redpoint,
  dogged,
  unfinished,
}

class RouteLog {
  final String id;
  final String routeId;
  final DateTime dateTime;
  final ClimbType climbType;
  final AscentType ascentType;

  const RouteLog({
    required this.id,
    required this.routeId,
    required this.dateTime,
    required this.climbType,
    required this.ascentType,
  });

  RouteLog copyWith({
    String? id,
    String? routeId,
    DateTime? dateTime,
    ClimbType? climbType,
    AscentType? ascentType,
  }) {
    return RouteLog(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      dateTime: dateTime ?? this.dateTime,
      climbType: climbType ?? this.climbType,
      ascentType: ascentType ?? this.ascentType,
    );
  }
}

extension ClimbTypeLabel on ClimbType {
  String get label {
    switch (this) {
      case ClimbType.lead:
        return '先锋';
      case ClimbType.topRope:
        return '顶绳';
      case ClimbType.bouldering:
        return '抱石';
    }
  }
}

extension AscentTypeLabel on AscentType {
  String get label {
    switch (this) {
      case AscentType.onsight:
        return 'onsight';
      case AscentType.flash:
        return 'flash';
      case AscentType.redpoint:
        return '红点';
      case AscentType.dogged:
        return 'dogged';
      case AscentType.unfinished:
        return '未完成';
    }
  }
}
