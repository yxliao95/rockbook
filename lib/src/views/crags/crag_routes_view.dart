import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/routes_provider.dart';
import '../common/route_log_dialog.dart';

class CragRoutesPage extends ConsumerWidget {
  final String cragId;
  final String cragName;

  const CragRoutesPage({super.key, required this.cragId, required this.cragName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesByCragProvider(cragId));

    return Scaffold(
      appBar: AppBar(title: Text(cragName)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final route = routes[index];
          return ListTile(
            title: Text(route.name),
            trailing: Text(route.grade),
            onTap: () => showDialog(context: context, builder: (_) => RouteLogDialog(route: route)),
          );
        },
      ),
    );
  }
}
