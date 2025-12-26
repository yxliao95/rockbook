import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../provider/crags_provider.dart';
import 'crag_routes_view.dart';

class CragDetailPage extends ConsumerWidget {
  final String cragId;

  const CragDetailPage({super.key, required this.cragId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Crag? crag = ref.watch(cragByIdProvider(cragId));
    final summary = ref.watch(cragSummaryProvider(cragId));
    final gradeDistribution = ref.watch(cragGradeDistributionProvider(cragId));
    final walls = ref.watch(wallsByCragProvider(cragId));

    if (crag == null) {
      return const Scaffold(body: Center(child: Text('未找到岩场信息')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(crag.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CragRoutesPage(cragId: crag.id, cragName: crag.name),
                ),
              );
            },
            child: const Text('查看所有线路'),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '基础信息',
            children: [
              _InfoRow(label: '石头类型', value: crag.rockType),
              _InfoRow(label: '预计接近时间', value: crag.approachTime),
              _InfoRow(label: '岩场暴露程度', value: crag.exposure),
              _InfoRow(label: '接近方式', value: crag.approachMethod),
              _InfoRow(label: '停车位置', value: crag.parking),
              _InfoRow(label: '岩壁', value: _wallNames(walls)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '线路信息',
            children: [
              _InfoRow(label: '线路数量', value: summary.routeCount.toString()),
              _InfoRow(label: '等级范围', value: summary.gradeRange),
              _GradeDistributionList(items: gradeDistribution),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '岩场概览图',
            children: [
              _ImagePlaceholder(label: crag.overviewImage),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '岩壁图集',
            children: crag.wallImages.map((image) => _ImagePlaceholder(label: image)).toList(),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '地图',
            children: [
              _ImagePlaceholder(label: crag.mapImage),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '天气预报',
            children: [
              Text(crag.weatherSummary ?? '暂无', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  String _wallNames(List<Wall> walls) {
    if (walls.isEmpty) return '暂无';
    return walls.map((wall) => wall.name).join('、');
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(child: Text(value ?? '暂无', style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _GradeDistributionList extends StatelessWidget {
  final List<GradeCount> items;

  const _GradeDistributionList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 110, child: Text('等级 ${item.grade}')),
                  Text('${item.count} 条'),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final String? label;

  const _ImagePlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(label ?? '暂无图片', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
