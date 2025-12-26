import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../provider/crags_provider.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
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
    final scopeKey = regionId == null ? 'region-tree:root' : 'region-tree:$regionId';
    final pageKey = regionId == null ? 'page:crags:root' : 'page:region:$regionId';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              _showRegionUpdateSheet(context, ref, childrenAsync, scopeKey, pageKey);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: title, scopeKeys: [scopeKey]);
            },
          ),
        ],
      ),
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
              CommentSection(targetKey: pageKey),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRegionUpdateSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<RegionChildren> childrenAsync,
    String scopeKey,
    String pageKey,
  ) async {
    final children = childrenAsync.asData?.value;
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
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('新增地区'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddRegionDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_business_outlined),
                title: const Text('新增岩场'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddCragDialog(context, ref);
                },
              ),
              if (regionId != null)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('重命名当前地区'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showRenameRegionDialog(context, ref);
                  },
                ),
              if (children != null && children.regions.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.merge_type),
                  title: const Text('地区合并/调整层级'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showMergeRegionDialog(context, ref, children.regions);
                  },
                ),
              if (children != null && children.regions.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('删除子地区'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteRegionDialog(context, ref, children.regions);
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
                    pageId: pageKey,
                    pageName: title,
                    scopeKeys: [scopeKey],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddRegionDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    RegionType selectedType = RegionType.region;
    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新增地区'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '地区名称', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RegionType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: '类型', border: OutlineInputBorder()),
                    items: RegionType.values
                        .map(
                          (type) => DropdownMenuItem(value: type, child: Text(type == RegionType.region ? '地区' : '区域')),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedType = value ?? selectedType),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(cragDataProvider.notifier)
                        .addRegion(
                          name: nameController.text.trim().isEmpty ? '新地区' : nameController.text.trim(),
                          parentId: regionId,
                          type: selectedType,
                        );
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

  Future<void> _showAddCragDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('新增岩场'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '岩场名称', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                if (regionId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择具体地区后再新增岩场')));
                  return;
                }
                ref
                    .read(cragDataProvider.notifier)
                    .addCrag(
                      regionId: regionId!,
                      name: nameController.text.trim().isEmpty ? '新岩场' : nameController.text.trim(),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('提交'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenameRegionDialog(BuildContext context, WidgetRef ref) async {
    if (regionId == null) return;
    final region = ref.read(regionByIdProvider(regionId!));
    if (region == null) return;
    final nameController = TextEditingController(text: region.name);
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('重命名地区'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '地区名称', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                ref
                    .read(cragDataProvider.notifier)
                    .renameRegion(
                      regionId: regionId!,
                      name: nameController.text.trim().isEmpty ? region.name : nameController.text.trim(),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('提交'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMergeRegionDialog(BuildContext context, WidgetRef ref, List<RegionNode> regions) async {
    final nameController = TextEditingController();
    RegionNode selectedRegion = regions.first;
    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('地区合并/调整层级'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '新上级地区名称', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RegionNode>(
                    initialValue: selectedRegion,
                    decoration: const InputDecoration(labelText: '选择要下移的地区', border: OutlineInputBorder()),
                    items: regions.map((region) => DropdownMenuItem(value: region, child: Text(region.name))).toList(),
                    onChanged: (value) => setState(() => selectedRegion = value ?? selectedRegion),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(cragDataProvider.notifier)
                        .mergeRegion(
                          parentId: regionId,
                          newRegionName: nameController.text.trim().isEmpty ? '新地区' : nameController.text.trim(),
                          childRegionId: selectedRegion.id,
                        );
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

  Future<void> _showDeleteRegionDialog(BuildContext context, WidgetRef ref, List<RegionNode> regions) async {
    RegionNode selectedRegion = regions.first;
    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('删除子地区'),
              content: DropdownButtonFormField<RegionNode>(
                initialValue: selectedRegion,
                decoration: const InputDecoration(labelText: '选择地区', border: OutlineInputBorder()),
                items: regions.map((region) => DropdownMenuItem(value: region, child: Text(region.name))).toList(),
                onChanged: (value) => setState(() => selectedRegion = value ?? selectedRegion),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                FilledButton(
                  onPressed: () {
                    final success = ref.read(cragDataProvider.notifier).deleteRegion(selectedRegion.id);
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该地区下仍有子地区或岩场，无法直接删除')));
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('确认删除'),
                ),
              ],
            );
          },
        );
      },
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
