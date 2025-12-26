import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../models/route_model.dart';
import '../../provider/crags_provider.dart';
import '../../provider/routes_provider.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
import '../common/route_log_dialog.dart';

/// 线路页面示例
class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(routeGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('线路'),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              _showRoutesUpdateSheet(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: '线路', scopeKeys: const ['scope:routes']);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _RoutesToolbar(),
          if (groups.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 24), child: Text('暂无符合条件的线路'))
          else
            ..._buildRouteSections(context, groups, ref),
          const SizedBox(height: 16),
          CommentSection(targetKey: 'page:routes'),
        ],
      ),
    );
  }

  List<Widget> _buildRouteSections(BuildContext context, List<RegionRouteGroup> groups, WidgetRef ref) {
    final widgets = <Widget>[];
    for (final group in groups) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(group.title, style: Theme.of(context).textTheme.titleMedium),
        ),
      );
      for (final cragGroup in group.crags) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(cragGroup.crag.name, style: Theme.of(context).textTheme.titleSmall),
          ),
        );
        widgets.addAll(
          cragGroup.routes.map(
            (route) => InkWell(
              onTap: () {
                if (!requireLogin(context, ref)) return;
                showDialog(
                  context: context,
                  builder: (_) => RouteLogDialog(route: route),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(route.name)),
                    Text(route.grade, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Future<void> _showRoutesUpdateSheet(BuildContext context, WidgetRef ref) async {
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
                leading: const Icon(Icons.add),
                title: const Text('新增线路'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRouteEditorDialog(context, ref, mode: _RouteEditMode.create);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑线路'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRouteEditorDialog(context, ref, mode: _RouteEditMode.update);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除线路'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRouteEditorDialog(context, ref, mode: _RouteEditMode.delete);
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
                    pageId: 'page:routes',
                    pageName: '线路',
                    scopeKeys: const ['scope:routes'],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRouteEditorDialog(BuildContext context, WidgetRef ref, {required _RouteEditMode mode}) async {
    final data = ref.read(cragDataProvider).asData?.value;
    if (data == null) return;
    final routes = [...data.routes]..sort((a, b) => a.name.compareTo(b.name));
    final crags = data.crags;
    if (crags.isEmpty) return;
    ClimbRoute? selectedRoute = routes.isNotEmpty ? routes.first : null;
    Crag? selectedCrag = crags.first;
    final initialWalls = data.walls.where((wall) => wall.cragId == selectedCrag?.id).toList();
    Wall? selectedWall = initialWalls.isNotEmpty ? initialWalls.first : null;
    RouteDiscipline selectedDiscipline = RouteDiscipline.sport;
    final nameController = TextEditingController(text: selectedRoute?.name ?? '');
    final gradeController = TextEditingController(text: selectedRoute?.grade ?? '5.10a');
    final orderController = TextEditingController(text: '1');

    if (selectedRoute != null && mode != _RouteEditMode.create) {
      selectedCrag = data.cragById(selectedRoute.cragId) ?? selectedCrag;
      selectedWall = data.wallById(selectedRoute.wallId);
      selectedDiscipline = selectedRoute.discipline;
      nameController.text = selectedRoute.name;
      gradeController.text = selectedRoute.grade;
      orderController.text = selectedRoute.order.toString();
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final wallOptions = data.walls.where((wall) => wall.cragId == selectedCrag!.id).toList();
            if (selectedWall == null && wallOptions.isNotEmpty) {
              selectedWall = wallOptions.first;
            }
            return AlertDialog(
              title: Text(mode.label),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mode != _RouteEditMode.create)
                      DropdownButtonFormField<ClimbRoute>(
                        initialValue: selectedRoute,
                        decoration: const InputDecoration(labelText: '选择线路', border: OutlineInputBorder()),
                        items: routes.map((route) => DropdownMenuItem(value: route, child: Text(route.name))).toList(),
                        onChanged: mode == _RouteEditMode.delete
                            ? (route) => setState(() => selectedRoute = route)
                            : (route) {
                                if (route == null) return;
                                setState(() {
                                  selectedRoute = route;
                                  selectedCrag = data.cragById(route.cragId) ?? selectedCrag;
                                  selectedWall = data.wallById(route.wallId);
                                  selectedDiscipline = route.discipline;
                                  nameController.text = route.name;
                                  gradeController.text = route.grade;
                                  orderController.text = route.order.toString();
                                });
                              },
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Crag>(
                      initialValue: selectedCrag,
                      decoration: const InputDecoration(labelText: '岩场', border: OutlineInputBorder()),
                      items: crags.map((crag) => DropdownMenuItem(value: crag, child: Text(crag.name))).toList(),
                      onChanged: mode == _RouteEditMode.delete
                          ? null
                          : (crag) {
                              if (crag == null) return;
                              setState(() {
                                selectedCrag = crag;
                                final walls = data.walls.where((wall) => wall.cragId == crag.id).toList();
                                selectedWall = walls.isNotEmpty ? walls.first : null;
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wall>(
                      initialValue: selectedWall,
                      decoration: const InputDecoration(labelText: '岩壁/巨石', border: OutlineInputBorder()),
                      items: wallOptions.map((wall) => DropdownMenuItem(value: wall, child: Text(wall.name))).toList(),
                      onChanged: mode == _RouteEditMode.delete ? null : (wall) => setState(() => selectedWall = wall),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '线路名称', border: OutlineInputBorder()),
                      enabled: mode != _RouteEditMode.delete,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: gradeController,
                      decoration: const InputDecoration(labelText: '难度', border: OutlineInputBorder()),
                      enabled: mode != _RouteEditMode.delete,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<RouteDiscipline>(
                      initialValue: selectedDiscipline,
                      decoration: const InputDecoration(labelText: '类型', border: OutlineInputBorder()),
                      items: RouteDiscipline.values
                          .map((discipline) => DropdownMenuItem(value: discipline, child: Text(discipline.label)))
                          .toList(),
                      onChanged: mode == _RouteEditMode.delete
                          ? null
                          : (value) => setState(() => selectedDiscipline = value ?? selectedDiscipline),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: orderController,
                      decoration: const InputDecoration(labelText: '排序', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      enabled: mode != _RouteEditMode.delete,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                FilledButton(
                  onPressed: () {
                    final notifier = ref.read(cragDataProvider.notifier);
                    if (mode == _RouteEditMode.delete && selectedRoute != null) {
                      notifier.deleteRoute(selectedRoute!.id);
                    } else if (mode == _RouteEditMode.update && selectedRoute != null) {
                      notifier.updateRoute(
                        selectedRoute!.copyWith(
                          name: nameController.text.trim(),
                          grade: gradeController.text.trim(),
                          discipline: selectedDiscipline,
                          wallId: selectedWall?.id ?? selectedRoute!.wallId,
                          cragId: selectedCrag!.id,
                          order: int.tryParse(orderController.text.trim()) ?? selectedRoute!.order,
                        ),
                      );
                    } else if (mode == _RouteEditMode.create) {
                      if (selectedCrag == null || selectedWall == null) return;
                      final newRoute = ClimbRoute(
                        id: 'route-${DateTime.now().microsecondsSinceEpoch}',
                        cragId: selectedCrag!.id,
                        wallId: selectedWall!.id,
                        order: int.tryParse(orderController.text.trim()) ?? 1,
                        name: nameController.text.trim().isEmpty ? '新线路' : nameController.text.trim(),
                        grade: gradeController.text.trim().isEmpty ? '5.10a' : gradeController.text.trim(),
                        discipline: selectedDiscipline,
                      );
                      notifier.addRoute(newRoute);
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
}

class _RoutesToolbar extends ConsumerWidget {
  const _RoutesToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = ref.watch(routesFilterProvider.select((state) => state.selectedCragIds.length));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.landscape_outlined),
              label: Text(selectedCount == 0 ? '选择岩场' : '已选岩场 $selectedCount'),
              onPressed: () {
                showDialog(context: context, builder: (_) => const _CragSelectDialog());
              },
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('过滤'),
            onPressed: () {
              showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => const _RouteFilterSheet());
            },
          ),
        ],
      ),
    );
  }
}

enum _RouteEditMode { create, update, delete }

extension _RouteEditModeLabel on _RouteEditMode {
  String get label {
    switch (this) {
      case _RouteEditMode.create:
        return '新增线路';
      case _RouteEditMode.update:
        return '编辑线路';
      case _RouteEditMode.delete:
        return '删除线路';
    }
  }
}

class _CragSelectDialog extends ConsumerWidget {
  const _CragSelectDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterNotifier = ref.read(routesFilterProvider.notifier);
    final rootChildren = ref.watch(regionChildrenProvider(null));

    return AlertDialog(
      title: const Text('选择岩场'),
      content: SizedBox(
        width: double.maxFinite,
        child: rootChildren.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('加载失败')),
          data: (children) {
            return ListView(
              shrinkWrap: true,
              children: children.regions
                  .map((region) => _RegionCragSelector(regionId: region.id, title: region.name))
                  .toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: filterNotifier.clearCrags, child: const Text('清空')),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('完成')),
      ],
    );
  }
}

class _RegionCragSelector extends ConsumerWidget {
  final String regionId;
  final String title;

  const _RegionCragSelector({required this.regionId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(regionChildrenProvider(regionId));
    final selectedCragIds = ref.watch(routesFilterProvider.select((state) => state.selectedCragIds));
    final filterNotifier = ref.read(routesFilterProvider.notifier);

    return ExpansionTile(
      title: Text(title),
      children: children.when(
        loading: () => [const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())],
        error: (_, _) => [const Padding(padding: EdgeInsets.all(12), child: Text('加载失败'))],
        data: (value) {
          final widgets = <Widget>[];
          widgets.addAll(value.regions.map((region) => _RegionCragSelector(regionId: region.id, title: region.name)));
          widgets.addAll(
            value.crags.map(
              (crag) => CheckboxListTile(
                value: selectedCragIds.contains(crag.id),
                title: Text(crag.name),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (_) => filterNotifier.toggleCrag(crag.id),
              ),
            ),
          );
          return widgets;
        },
      ),
    );
  }
}

class _RouteFilterSheet extends ConsumerWidget {
  const _RouteFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(routeFilterOptionsProvider);
    final state = ref.watch(routesFilterProvider);
    final filterNotifier = ref.read(routesFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ListView(
        children: [
          _FilterSection(
            title: '难度',
            options: options.grades,
            selected: state.grades,
            onTap: filterNotifier.toggleGrade,
          ),
          _FilterSection(title: '类型', options: options.types, selected: state.types, onTap: filterNotifier.toggleType),
          _FilterSection(
            title: '风格',
            options: options.styles,
            selected: state.styles,
            onTap: filterNotifier.toggleStyle,
          ),
          _FilterSection<int>(
            title: '快挂数量',
            options: options.quickdraws,
            selected: state.quickdraws,
            labelBuilder: (value) => '$value 挂',
            onTap: filterNotifier.toggleQuickdraws,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: filterNotifier.clearFilters, child: const Text('清空过滤')),
          ),
        ],
      ),
    );
  }
}

class _FilterSection<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final Set<T> selected;
  final void Function(T value) onTap;
  final String Function(T value)? labelBuilder;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onTap,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => FilterChip(
                    label: Text(labelBuilder?.call(option) ?? option.toString()),
                    selected: selected.contains(option),
                    onSelected: (_) => onTap(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
