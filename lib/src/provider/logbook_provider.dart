import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/route_log_model.dart';
import '../provider/crags_provider.dart';
import '../provider/user_provider.dart';

class RouteLogsNotifier extends Notifier<List<RouteLog>> {
  @override
  List<RouteLog> build() {
    final data = ref.watch(cragDataProvider).asData?.value;
    final routes = data?.routes ?? const [];
    if (routes.isEmpty) return const [];
    final sampleRoutes = routes.take(3).toList();
    if (sampleRoutes.length < 3) return const [];
    return [
      RouteLog(
        id: 'log-u1-1',
        routeId: sampleRoutes[0].id,
        userId: 'u1',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        climbType: ClimbType.lead,
        ascentType: AscentType.redpoint,
        belayerName: '石头',
        belayerUserId: 'u3',
      ),
      RouteLog(
        id: 'log-u2-1',
        routeId: sampleRoutes[1].id,
        userId: 'u2',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        climbType: ClimbType.topRope,
        ascentType: AscentType.flash,
        belayerName: '阿岩',
        belayerUserId: 'u1',
      ),
      RouteLog(
        id: 'log-u3-1',
        routeId: sampleRoutes[2].id,
        userId: 'u3',
        dateTime: DateTime.now().subtract(const Duration(hours: 6)),
        climbType: ClimbType.bouldering,
        ascentType: AscentType.send,
        belayerName: '木木',
        belayerUserId: 'u2',
      ),
    ];
  }

  void addLog(RouteLog log) {
    state = [...state, log];
  }

  void updateLog(RouteLog log) {
    final next = [...state];
    final index = next.indexWhere((item) => item.id == log.id);
    if (index == -1) {
      next.add(log);
    } else {
      next[index] = log;
    }
    state = next;
  }
}

final routeLogsProvider = NotifierProvider<RouteLogsNotifier, List<RouteLog>>(RouteLogsNotifier.new);

final userRouteLogsProvider = Provider<List<RouteLog>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(routeLogsProvider).where((log) => log.userId == user.id).toList();
});
