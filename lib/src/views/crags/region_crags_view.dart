import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crag_model.dart';
import '../../provider/crags_provider.dart';
import 'crag_detail_view.dart';

class RegionCragsPage extends ConsumerWidget {
  final Region region;

  const RegionCragsPage({super.key, required this.region});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crags = ref.watch(cragsByRegionProvider(region.id));

    return Scaffold(
      appBar: AppBar(title: Text(region.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: crags.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final CragSummary crag = crags[index];
          return Card(
            child: ListTile(
              title: Text(crag.name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text('线路 ${crag.routeCount} · 等级 ${crag.gradeRange} · 攀登 ${crag.ascents}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CragDetailPage(cragId: crag.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
