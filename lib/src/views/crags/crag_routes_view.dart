import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/region_model.dart';
import '../../models/route_model.dart';
import '../../provider/crags_provider.dart';
import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';
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
      appBar: AppBar(
        title: Text(cragName),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              _showCragRoutesUpdateSheet(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: cragName, scopeKeys: ['crag:$cragId']);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildWallSections(context, ref, walls, routes),
          CommentSection(targetKey: 'page:crag-routes:$cragId'),
        ],
      ),
    );
  }

  List<Widget> _buildWallSections(BuildContext context, WidgetRef ref, List<Wall> walls, List<ClimbRoute> routes) {
    if (walls.isEmpty) {
      return routes
          .map(
            (route) => ListTile(
              title: Text(route.name),
              trailing: Text(route.grade),
              onTap: () {
                if (!requireLogin(context, ref)) return;
                showDialog(
                  context: context,
                  builder: (_) => RouteLogDialog(route: route),
                );
              },
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
            onTap: () {
              if (!requireLogin(context, ref)) return;
              showDialog(
                context: context,
                builder: (_) => RouteLogDialog(route: route),
              );
            },
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

  Future<void> _showCragRoutesUpdateSheet(BuildContext context, WidgetRef ref) async {
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
                    pageId: 'page:crag-routes:$cragId',
                    pageName: cragName,
                    scopeKeys: ['crag:$cragId'],
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
    final routes = data.routesByCrag(cragId);
    if (routes.isEmpty && mode != _RouteEditMode.create) return;
    ClimbRoute? selectedRoute = routes.isNotEmpty ? routes.first : null;
    final walls = data.wallsByCrag(cragId);
    Wall? selectedWall = walls.isNotEmpty ? walls.first : null;
    RouteDiscipline selectedDiscipline = selectedRoute?.discipline ?? RouteDiscipline.sport;
    final nameController = TextEditingController(text: selectedRoute?.name ?? '');
    final gradeController = TextEditingController(text: selectedRoute?.grade ?? '5.10a');
    final orderController = TextEditingController(text: selectedRoute?.order.toString() ?? '1');

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                                  selectedWall = data.wallById(route.wallId);
                                  selectedDiscipline = route.discipline;
                                  nameController.text = route.name;
                                  gradeController.text = route.grade;
                                  orderController.text = route.order.toString();
                                });
                              },
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wall>(
                      initialValue: selectedWall,
                      decoration: const InputDecoration(labelText: '岩壁/抱石区', border: OutlineInputBorder()),
                      items: walls.map((wall) => DropdownMenuItem(value: wall, child: Text(wall.name))).toList(),
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
                          order: int.tryParse(orderController.text.trim()) ?? selectedRoute!.order,
                        ),
                      );
                    } else if (mode == _RouteEditMode.create) {
                      if (selectedWall == null) return;
                      final newRoute = ClimbRoute(
                        id: 'route-${DateTime.now().microsecondsSinceEpoch}',
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
