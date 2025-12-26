enum ClimbType {
  lead,
  topRope,
  follow,
  bouldering,
}

enum AscentType {
  onsight,
  flash,
  redpoint,
  pinkpoint,
  clean,
  hangdog,
  send,
  repeat,
  dab,
  generalAscent,
  attempt,
  working,
  retreat,
}

class RouteLog {
  final String id;
  final String routeId;
  final String userId;
  final DateTime dateTime;
  final ClimbType climbType;
  final AscentType ascentType;
  final String? belayerName;
  final String? belayerUserId;

  const RouteLog({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.dateTime,
    required this.climbType,
    required this.ascentType,
    this.belayerName,
    this.belayerUserId,
  });

  RouteLog copyWith({
    String? id,
    String? routeId,
    String? userId,
    DateTime? dateTime,
    ClimbType? climbType,
    AscentType? ascentType,
    String? belayerName,
    String? belayerUserId,
  }) {
    return RouteLog(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      climbType: climbType ?? this.climbType,
      ascentType: ascentType ?? this.ascentType,
      belayerName: belayerName ?? this.belayerName,
      belayerUserId: belayerUserId ?? this.belayerUserId,
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
      case ClimbType.follow:
        return '跟攀';
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
      case AscentType.pinkpoint:
        return '粉点';
      case AscentType.clean:
        return '干净完成';
      case AscentType.hangdog:
        return '挂点';
      case AscentType.send:
        return '完成';
      case AscentType.repeat:
        return '重复';
      case AscentType.dab:
        return '触地';
      case AscentType.generalAscent:
        return '完攀';
      case AscentType.attempt:
        return '尝试';
      case AscentType.working:
        return '磕线';
      case AscentType.retreat:
        return '下撤';
    }
  }
}
