import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/change_log_model.dart';
import '../models/region_model.dart';
import '../models/route_model.dart';
import '../provider/change_log_provider.dart';
import '../provider/user_provider.dart';
import '../services/crag_data_service.dart';

final cragDataProvider = AsyncNotifierProvider<CragDataNotifier, CragDataStore>(CragDataNotifier.new);

class CragDataNotifier extends AsyncNotifier<CragDataStore> {
  @override
  Future<CragDataStore> build() async {
    return CragDataService.instance.load();
  }

  void addRegion({required String name, required String? parentId, RegionType type = RegionType.region}) {
    final store = state.asData?.value;
    if (store == null) return;
    final region = RegionNode(
      id: _newId('r'),
      name: name,
      parentId: parentId,
      type: type,
    );
    final updated = _rebuildStore(store, regions: [...store.regions, region]);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.region,
      targetId: region.id,
      targetName: region.name,
      action: ChangeAction.create,
      scopeKeys: _regionScopeKeys(region, parentId),
    );
  }

  void renameRegion({required String regionId, required String name}) {
    final store = state.asData?.value;
    if (store == null) return;
    final updatedRegions = store.regions.map((region) {
      return region.id == regionId ? region.copyWith(name: name) : region;
    }).toList();
    final updated = _rebuildStore(store, regions: updatedRegions);
    state = AsyncValue.data(updated);
    final region = updated.regionById(regionId);
    if (region != null) {
      _logChange(
        targetType: ChangeTargetType.region,
        targetId: region.id,
        targetName: region.name,
        action: ChangeAction.update,
        scopeKeys: _regionScopeKeys(region, region.parentId),
      );
    }
  }

  bool deleteRegion(String regionId) {
    final store = state.asData?.value;
    if (store == null) return false;
    if (store.childRegions(regionId).isNotEmpty || store.cragsByRegion(regionId).isNotEmpty) {
      return false;
    }
    final region = store.regionById(regionId);
    if (region == null) return false;
    final updatedRegions = store.regions.where((region) => region.id != regionId).toList();
    final updated = _rebuildStore(store, regions: updatedRegions);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.region,
      targetId: regionId,
      targetName: region.name,
      action: ChangeAction.delete,
      scopeKeys: _regionScopeKeys(region, region.parentId),
    );
    return true;
  }

  void mergeRegion({required String? parentId, required String newRegionName, required String childRegionId}) {
    final store = state.asData?.value;
    if (store == null) return;
    final newRegion = RegionNode(id: _newId('r'), name: newRegionName, parentId: parentId, type: RegionType.region);
    final updatedRegions = store.regions
        .map((region) => region.id == childRegionId ? region.copyWith(parentId: newRegion.id) : region)
        .toList();
    updatedRegions.add(newRegion);
    final updated = _rebuildStore(store, regions: updatedRegions);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.region,
      targetId: newRegion.id,
      targetName: newRegion.name,
      action: ChangeAction.merge,
      description: '合并/调整地区层级',
      scopeKeys: _regionScopeKeys(newRegion, parentId),
    );
  }

  void addCrag({required String regionId, required String name}) {
    final store = state.asData?.value;
    if (store == null) return;
    final crag = Crag(id: _newId('c'), regionId: regionId, name: name);
    final wall = Wall(id: _newId('w'), cragId: crag.id, name: '主壁', type: WallType.cliff);
    final updated = _rebuildStore(store, crags: [...store.crags, crag], walls: [...store.walls, wall]);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.crag,
      targetId: crag.id,
      targetName: crag.name,
      action: ChangeAction.create,
      scopeKeys: _cragScopeKeys(crag),
    );
  }

  void updateCrag(Crag updatedCrag) {
    final store = state.asData?.value;
    if (store == null) return;
    final updatedCrags = store.crags.map((crag) => crag.id == updatedCrag.id ? updatedCrag : crag).toList();
    final updated = _rebuildStore(store, crags: updatedCrags);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.crag,
      targetId: updatedCrag.id,
      targetName: updatedCrag.name,
      action: ChangeAction.update,
      scopeKeys: _cragScopeKeys(updatedCrag),
    );
  }

  void deleteCrag(String cragId) {
    final store = state.asData?.value;
    if (store == null) return;
    final crag = store.cragById(cragId);
    if (crag == null) return;
    final updatedCrags = store.crags.where((crag) => crag.id != cragId).toList();
    final updatedWalls = store.walls.where((wall) => wall.cragId != cragId).toList();
    final updatedRoutes = store.routes.where((route) => route.cragId != cragId).toList();
    final updated = _rebuildStore(store, crags: updatedCrags, walls: updatedWalls, routes: updatedRoutes);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.crag,
      targetId: cragId,
      targetName: crag.name,
      action: ChangeAction.delete,
      scopeKeys: _cragScopeKeys(crag),
    );
  }

  void addWall({required String cragId, required String name, required WallType type}) {
    final store = state.asData?.value;
    if (store == null) return;
    final wall = Wall(id: _newId('w'), cragId: cragId, name: name, type: type);
    final updated = _rebuildStore(store, walls: [...store.walls, wall]);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.wall,
      targetId: wall.id,
      targetName: wall.name,
      action: ChangeAction.create,
      scopeKeys: _wallScopeKeys(wall, store),
    );
  }

  void updateWall(Wall updatedWall) {
    final store = state.asData?.value;
    if (store == null) return;
    final updatedWalls = store.walls.map((wall) => wall.id == updatedWall.id ? updatedWall : wall).toList();
    final updated = _rebuildStore(store, walls: updatedWalls);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.wall,
      targetId: updatedWall.id,
      targetName: updatedWall.name,
      action: ChangeAction.update,
      scopeKeys: _wallScopeKeys(updatedWall, store),
    );
  }

  void deleteWall(String wallId) {
    final store = state.asData?.value;
    if (store == null) return;
    final wall = store.wallById(wallId);
    if (wall == null) return;
    final updatedWalls = store.walls.where((wall) => wall.id != wallId).toList();
    final updatedRoutes = store.routes.where((route) => route.wallId != wallId).toList();
    final updated = _rebuildStore(store, walls: updatedWalls, routes: updatedRoutes);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.wall,
      targetId: wall.id,
      targetName: wall.name,
      action: ChangeAction.delete,
      scopeKeys: _wallScopeKeys(wall, store),
    );
  }

  void addRoute(ClimbRoute route) {
    final store = state.asData?.value;
    if (store == null) return;
    final updated = _rebuildStore(store, routes: [...store.routes, route]);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.route,
      targetId: route.id,
      targetName: route.name,
      action: ChangeAction.create,
      scopeKeys: _routeScopeKeys(route, store),
    );
  }

  void updateRoute(ClimbRoute route) {
    final store = state.asData?.value;
    if (store == null) return;
    final updatedRoutes = store.routes.map((item) => item.id == route.id ? route : item).toList();
    final updated = _rebuildStore(store, routes: updatedRoutes);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.route,
      targetId: route.id,
      targetName: route.name,
      action: ChangeAction.update,
      scopeKeys: _routeScopeKeys(route, store),
    );
  }

  void deleteRoute(String routeId) {
    final store = state.asData?.value;
    if (store == null) return;
    final route = store.routes.where((route) => route.id == routeId).firstOrNull;
    if (route == null) return;
    final updatedRoutes = store.routes.where((route) => route.id != routeId).toList();
    final updated = _rebuildStore(store, routes: updatedRoutes);
    state = AsyncValue.data(updated);
    _logChange(
      targetType: ChangeTargetType.route,
      targetId: routeId,
      targetName: route.name,
      action: ChangeAction.delete,
      scopeKeys: _routeScopeKeys(route, store),
    );
  }

  CragDataStore _rebuildStore(
    CragDataStore store, {
    List<RegionNode>? regions,
    List<Crag>? crags,
    List<Wall>? walls,
    List<ClimbRoute>? routes,
  }) {
    final nextRegions = regions ?? store.regions;
    return CragDataStore(
      regions: nextRegions,
      relations: CragDataService.buildRelations(nextRegions),
      crags: crags ?? store.crags,
      walls: walls ?? store.walls,
      routes: routes ?? store.routes,
    );
  }

  String _newId(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}';

  List<String> _regionScopeKeys(RegionNode region, String? parentId) {
    final keys = <String>['scope:crags', 'region:${region.id}', 'region-tree:${region.id}'];
    if (parentId != null) {
      keys.add('region-tree:$parentId');
    } else {
      keys.add('region-tree:root');
    }
    return keys;
  }

  List<String> _cragScopeKeys(Crag crag) {
    return ['scope:crags', 'crag:${crag.id}', 'region:${crag.regionId}', 'region-tree:${crag.regionId}'];
  }

  List<String> _wallScopeKeys(Wall wall, CragDataStore store) {
    final crag = store.cragById(wall.cragId);
    final regionId = crag?.regionId;
    return [
      'scope:crags',
      'wall:${wall.id}',
      'crag:${wall.cragId}',
      if (regionId != null) 'region:$regionId',
      if (regionId != null) 'region-tree:$regionId',
    ];
  }

  List<String> _routeScopeKeys(ClimbRoute route, CragDataStore store) {
    final crag = store.cragById(route.cragId);
    final regionId = crag?.regionId;
    return [
      'scope:routes',
      'route:${route.id}',
      'crag:${route.cragId}',
      if (regionId != null) 'region:$regionId',
      if (regionId != null) 'region-tree:$regionId',
    ];
  }

  void _logChange({
    required ChangeTargetType targetType,
    required String targetId,
    required String targetName,
    required ChangeAction action,
    required List<String> scopeKeys,
    String? description,
  }) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref.read(changeLogProvider.notifier).addEntry(
      ChangeLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        userId: user.id,
        userName: user.nickname,
        targetType: targetType,
        targetId: targetId,
        targetName: targetName,
        action: action,
        timestamp: DateTime.now(),
        description: description,
        scopeKeys: scopeKeys,
      ),
    );
  }
}

final regionChildrenProvider = Provider.family<AsyncValue<RegionChildren>, String?>((ref, regionId) {
  return ref.watch(cragDataProvider).whenData((data) {
    return RegionChildren(regions: data.childRegions(regionId), crags: data.cragsByRegion(regionId));
  });
});

final regionByIdProvider = Provider.family<RegionNode?, String>((ref, regionId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.regionById(regionId);
});

final regionSummaryProvider = Provider.family<GradeSummary, String>((ref, regionId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.regionSummary(regionId) ?? const GradeSummary.empty();
});

final cragByIdProvider = Provider.family<Crag?, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.cragById(cragId);
});

final cragSummaryProvider = Provider.family<GradeSummary, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.cragSummary(cragId) ?? const GradeSummary.empty();
});

final cragGradeDistributionProvider = Provider.family<List<GradeCount>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.gradeDistribution(cragId) ?? const [];
});

final wallsByCragProvider = Provider.family<List<Wall>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.wallsByCrag(cragId) ?? const [];
});

final routesByCragProvider = Provider.family<List<ClimbRoute>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.routesByCrag(cragId) ?? const [];
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
