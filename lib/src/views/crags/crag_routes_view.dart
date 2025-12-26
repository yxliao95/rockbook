import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../models/route_model.dart';
import '../../provider/crags_provider.dart';
import '../common/route_log_dialog.dart';

class CragRoutesPage extends ConsumerWidget {
  final String cragId;
  final String cragName;

  const CragRoutesPage({super.key, required this.cragId, required this.cragName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = [...ref.watch(routesByCragProvider(cragId))]..sort((a, b) => a.order.compareTo(b.order));
    final walls = ref.watch(wallsByCragProvider(cragId));

    return Scaffold(
      appBar: AppBar(title: Text(cragName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _buildWallSections(context, walls, routes),
      ),
    );
  }

  List<Widget> _buildWallSections(BuildContext context, List<Wall> walls, List<ClimbRoute> routes) {
    if (walls.isEmpty) {
      return routes
          .map(
            (route) => ListTile(
              title: Text(route.name),
              trailing: Text(route.grade),
              onTap: () => showDialog(context: context, builder: (_) => RouteLogDialog(route: route)),
            ),
          )
          .toList();
    }

    final routeByWall = <String, List<ClimbRoute>>{};
    for (final route in routes) {
      routeByWall.putIfAbsent(route.wallId, () => []).add(route);
    }

    final widgets = <Widget>[];
    for (final wall in walls) {
      final wallRoutes = routeByWall[wall.id] ?? const [];
      if (wallRoutes.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(wall.name, style: Theme.of(context).textTheme.titleMedium),
        ),
      );
      widgets.addAll(
        wallRoutes.map(
          (route) => ListTile(
            title: Text(route.name),
            trailing: Text(route.grade),
            onTap: () => showDialog(context: context, builder: (_) => RouteLogDialog(route: route)),
          ),
        ),
      );
      widgets.add(const Divider(height: 24));
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }
}
