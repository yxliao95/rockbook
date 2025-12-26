import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../provider/crags_provider.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
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
      appBar: AppBar(
        title: Text(crag.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              _showCragUpdateSheet(context, ref, crag, walls);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: crag.name, scopeKeys: ['crag:${crag.id}']);
            },
          ),
        ],
      ),
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
            children: [_ImagePlaceholder(label: crag.overviewImage)],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '岩壁图集',
            children: crag.wallImages.map((image) => _ImagePlaceholder(label: image)).toList(),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '地图',
            children: [_ImagePlaceholder(label: crag.mapImage)],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '天气预报',
            children: [Text(crag.weatherSummary ?? '暂无', style: Theme.of(context).textTheme.bodyMedium)],
          ),
          CommentSection(targetKey: 'page:crag:${crag.id}'),
        ],
      ),
    );
  }

  String _wallNames(List<Wall> walls) {
    if (walls.isEmpty) return '暂无';
    return walls.map((wall) => wall.name).join('、');
  }

  Future<void> _showCragUpdateSheet(BuildContext context, WidgetRef ref, Crag crag, List<Wall> walls) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑岩场信息'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCragEditDialog(context, ref, crag);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('新增岩壁/巨石'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showWallEditor(context, ref, crag, walls, mode: _WallEditMode.create);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_attributes_outlined),
                title: const Text('编辑岩壁/巨石'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showWallEditor(context, ref, crag, walls, mode: _WallEditMode.update);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除岩壁/巨石'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showWallEditor(context, ref, crag, walls, mode: _WallEditMode.delete);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: const Text('删除岩场'),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteCrag(context, ref, crag);
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('提交更新说明'),
                onTap: () {
                  Navigator.of(context).pop();
                  showPageUpdateDialog(
                    context: context,
                    ref: ref,
                    pageId: 'page:crag:${crag.id}',
                    pageName: crag.name,
                    scopeKeys: ['crag:${crag.id}'],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCragEditDialog(BuildContext context, WidgetRef ref, Crag crag) async {
    final nameController = TextEditingController(text: crag.name);
    final rockController = TextEditingController(text: crag.rockType ?? '');
    final approachTimeController = TextEditingController(text: crag.approachTime ?? '');
    final exposureController = TextEditingController(text: crag.exposure ?? '');
    final approachController = TextEditingController(text: crag.approachMethod ?? '');
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('编辑岩场信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '岩场名称', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rockController,
                  decoration: const InputDecoration(labelText: '石头类型', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: approachTimeController,
                  decoration: const InputDecoration(labelText: '接近时间', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: exposureController,
                  decoration: const InputDecoration(labelText: '暴露程度', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: approachController,
                  decoration: const InputDecoration(labelText: '接近方式', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                ref
                    .read(cragDataProvider.notifier)
                    .updateCrag(
                      crag.copyWith(
                        name: nameController.text.trim().isEmpty ? crag.name : nameController.text.trim(),
                        rockType: rockController.text.trim(),
                        approachTime: approachTimeController.text.trim(),
                        exposure: exposureController.text.trim(),
                        approachMethod: approachController.text.trim(),
                      ),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWallEditor(
    BuildContext context,
    WidgetRef ref,
    Crag crag,
    List<Wall> walls, {
    required _WallEditMode mode,
  }) async {
    if (walls.isEmpty && mode != _WallEditMode.create) return;
    Wall? selectedWall = walls.isNotEmpty ? walls.first : null;
    final nameController = TextEditingController(text: selectedWall?.name ?? '');
    WallType selectedType = selectedWall?.type ?? WallType.cliff;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(mode.label),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mode != _WallEditMode.create)
                    DropdownButtonFormField<Wall>(
                      initialValue: selectedWall,
                      decoration: const InputDecoration(labelText: '选择岩壁', border: OutlineInputBorder()),
                      items: walls.map((wall) => DropdownMenuItem(value: wall, child: Text(wall.name))).toList(),
                      onChanged: (wall) {
                        if (wall == null) return;
                        setState(() {
                          selectedWall = wall;
                          nameController.text = wall.name;
                          selectedType = wall.type;
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '岩壁名称', border: OutlineInputBorder()),
                    enabled: mode != _WallEditMode.delete,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<WallType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: '类型', border: OutlineInputBorder()),
                    items: WallType.values
                        .map((type) => DropdownMenuItem(value: type, child: Text(type == WallType.cliff ? '岩壁' : '巨石')))
                        .toList(),
                    onChanged: mode == _WallEditMode.delete
                        ? null
                        : (value) => setState(() => selectedType = value ?? selectedType),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                FilledButton(
                  onPressed: () {
                    final notifier = ref.read(cragDataProvider.notifier);
                    if (mode == _WallEditMode.delete && selectedWall != null) {
                      notifier.deleteWall(selectedWall!.id);
                    } else if (mode == _WallEditMode.update && selectedWall != null) {
                      notifier.updateWall(
                        selectedWall!.copyWith(
                          name: nameController.text.trim().isEmpty ? selectedWall!.name : nameController.text.trim(),
                          type: selectedType,
                        ),
                      );
                    } else if (mode == _WallEditMode.create) {
                      notifier.addWall(
                        cragId: crag.id,
                        name: nameController.text.trim().isEmpty ? '新岩壁' : nameController.text.trim(),
                        type: selectedType,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('提交'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCrag(BuildContext context, WidgetRef ref, Crag crag) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('删除岩场'),
          content: Text('确定删除 ${crag.name} 吗？相关岩壁与线路也将删除。'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                ref.read(cragDataProvider.notifier).deleteCrag(crag.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('确认删除'),
            ),
          ],
        );
      },
    );
  }
}

enum _WallEditMode { create, update, delete }

extension _WallEditModeLabel on _WallEditMode {
  String get label {
    switch (this) {
      case _WallEditMode.create:
        return '新增岩壁/巨石';
      case _WallEditMode.update:
        return '编辑岩壁/巨石';
      case _WallEditMode.delete:
        return '删除岩壁/巨石';
    }
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
