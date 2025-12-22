import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/route_log_model.dart';

class RouteLogsNotifier extends Notifier<List<RouteLog>> {
  @override
  List<RouteLog> build() => const [];

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
