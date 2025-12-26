import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../provider/crags_provider.dart';
import 'crag_detail_view.dart';

/// 岩场页面示例
class CragsPage extends ConsumerWidget {
  const CragsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RegionListPage(regionId: null, title: '岩场');
  }
}

class RegionListPage extends ConsumerWidget {
  final String? regionId;
  final String title;

  const RegionListPage({super.key, required this.regionId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(regionChildrenProvider(regionId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('regionChildrenProvider error: $e');
          debugPrintStack(stackTrace: st);
          return Center(child: Text('加载失败：$e'));
        },
        data: (children) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (children.regions.isNotEmpty) _RegionSection(regions: children.regions),
              if (children.crags.isNotEmpty) _CragSection(crags: children.crags),
            ],
          );
        },
      ),
    );
  }
}

class _RegionSection extends ConsumerWidget {
  final List<RegionNode> regions;

  const _RegionSection({required this.regions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('地区', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...regions.map((region) {
          final summary = ref.watch(regionSummaryProvider(region.id));
          return Card(
            child: ListTile(
              title: Text(region.name),
              subtitle: Text('线路 ${summary.routeCount} · 等级 ${summary.gradeRange}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegionListPage(regionId: region.id, title: region.name),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _CragSection extends ConsumerWidget {
  final List<Crag> crags;

  const _CragSection({required this.crags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('岩场', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...crags.map((crag) {
          final summary = ref.watch(cragSummaryProvider(crag.id));
          return Card(
            child: ListTile(
              title: Text(crag.name),
              subtitle: Text('线路 ${summary.routeCount} · 等级 ${summary.gradeRange}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => CragDetailPage(cragId: crag.id)));
              },
            ),
          );
        }),
      ],
    );
  }
}
