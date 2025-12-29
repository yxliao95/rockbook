import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/region_model.dart';
import '../models/route_model.dart';

class CragDataStore {
  final List<RegionNode> regions;
  final List<RegionRelation> relations;
  final List<Crag> crags;
  final List<Zone> zones;
  final List<Wall> walls;
  final List<ClimbRoute> routes;

  final Map<String, RegionNode> _regionsById;
  final Map<String, Crag> _cragsById;
  final Map<String, Zone> _zonesById;
  final Map<String, Wall> _wallsById;
  final Map<String, List<String>> _regionChildren;
  final Map<String, List<String>> _regionCrags;
  final Map<String, List<String>> _cragZones;
  final Map<String, List<String>> _cragWalls;
  final Map<String, List<String>> _zoneWalls;
  final Map<String, List<String>> _wallRoutes;
  final Map<String, String> _wallCrag;

  CragDataStore({
    required this.regions,
    required this.relations,
    required this.crags,
    required this.zones,
    required this.walls,
    required this.routes,
  }) : _regionsById = {for (final region in regions) region.id: region},
       _cragsById = {for (final crag in crags) crag.id: crag},
       _zonesById = {for (final zone in zones) zone.id: zone},
       _wallsById = {for (final wall in walls) wall.id: wall},
       _regionChildren = _buildRegionChildren(regions),
       _regionCrags = _buildRegionCrags(crags),
       _cragZones = _buildCragZones(zones),
       _cragWalls = _buildCragWalls(walls, {for (final zone in zones) zone.id: zone}),
       _zoneWalls = _buildZoneWalls(walls),
       _wallCrag = _buildWallCrag(walls, {for (final zone in zones) zone.id: zone}),
       _wallRoutes = _buildWallRoutes(routes);

  List<RegionNode> rootRegions() => regions.where((region) => region.parentId == null).toList();

  RegionNode? regionById(String id) => _regionsById[id];

  Crag? cragById(String id) => _cragsById[id];

  Zone? zoneById(String id) => _zonesById[id];

  Wall? wallById(String id) => _wallsById[id];

  List<RegionNode> childRegions(String? regionId) {
    final key = regionId ?? 'root';
    final ids = _regionChildren[key] ?? const [];
    return ids.map((id) => _regionsById[id]).whereType<RegionNode>().toList();
  }

  List<Crag> cragsByRegion(String? regionId) {
    if (regionId == null) return const [];
    final ids = _regionCrags[regionId] ?? const [];
    return ids.map((id) => _cragsById[id]).whereType<Crag>().toList();
  }

  List<Wall> wallsByCrag(String cragId) {
    final ids = _cragWalls[cragId] ?? const [];
    return ids.map((id) => _wallsById[id]).whereType<Wall>().toList();
  }

  List<Zone> zonesByCrag(String cragId) {
    final ids = _cragZones[cragId] ?? const [];
    return ids.map((id) => _zonesById[id]).whereType<Zone>().toList();
  }

  List<Wall> wallsByZone(String zoneId) {
    final ids = _zoneWalls[zoneId] ?? const [];
    return ids.map((id) => _wallsById[id]).whereType<Wall>().toList();
  }

  List<String> wallIdsByCrag(String cragId) => _cragWalls[cragId] ?? const [];

  List<ClimbRoute> routesByCrag(String cragId) {
    return routes.where((route) => _wallCrag[route.wallId] == cragId).toList();
  }

  List<ClimbRoute> routesByWall(String wallId) {
    final ids = _wallRoutes[wallId] ?? const [];
    return ids.map((id) => routes.firstWhere((route) => route.id == id)).toList();
  }

  String? cragIdForWall(String wallId) => _wallCrag[wallId];

  String? cragIdForRoute(ClimbRoute route) => _wallCrag[route.wallId];

  CragDataStore reparentRegion({required String regionId, required String? newParentId}) {
    final updatedRegions = regions
        .map((region) => region.id == regionId ? region.copyWith(parentId: newParentId) : region)
        .toList();
    final updatedRelations = CragDataService._buildRelations(updatedRegions);
    return CragDataStore(
      regions: updatedRegions,
      relations: updatedRelations,
      crags: crags,
      zones: zones,
      walls: walls,
      routes: routes,
    );
  }

  String regionPath(String regionId) {
    final names = <String>[];
    RegionNode? current = _regionsById[regionId];
    while (current != null) {
      names.add(current.name);
      final parentId = current.parentId;
      current = parentId == null ? null : _regionsById[parentId];
    }
    return names.reversed.join('-');
  }

  GradeSummary cragSummary(String cragId) {
    final cragRoutes = routesByCrag(cragId);
    return _summaryFromRoutes(cragRoutes);
  }

  GradeSummary regionSummary(String regionId) {
    final regionRoutes = _routesByRegionTree(regionId);
    return _summaryFromRoutes(regionRoutes);
  }

  List<GradeCount> gradeDistribution(String cragId) {
    final cragRoutes = routesByCrag(cragId);
    final counts = <String, int>{};
    for (final route in cragRoutes) {
      counts.update(route.grade, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts.entries.map((entry) => GradeCount(grade: entry.key, count: entry.value)).toList();
  }

  List<ClimbRoute> _routesByRegionTree(String regionId) {
    final regionCrags = cragsByRegion(regionId);
    final childRegionIds = _regionChildren[regionId] ?? const [];
    final childRoutes = childRegionIds.expand(_routesByRegionTree);
    return [...regionCrags.expand((crag) => routesByCrag(crag.id)), ...childRoutes];
  }

  GradeSummary _summaryFromRoutes(List<ClimbRoute> routes) {
    if (routes.isEmpty) return const GradeSummary.empty();
    final gradeSamples = routes.map((route) => _normalizeGrade(route.grade)).whereType<String>();
    final gradeBuckets = _groupGrades(gradeSamples);
    if (gradeBuckets.isEmpty) {
      return GradeSummary(routeCount: routes.length, gradeRange: '-');
    }
    final dominant = gradeBuckets.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));
    final grades = dominant.first.value;
    grades.sort((a, b) => a.index.compareTo(b.index));
    final min = grades.first.label;
    final max = grades.last.label;
    final range = min == max ? min : '$min - $max';
    return GradeSummary(routeCount: routes.length, gradeRange: range);
  }

  Map<GradeScale, List<_GradeValue>> _groupGrades(Iterable<String> grades) {
    final map = <GradeScale, List<_GradeValue>>{};
    for (final grade in grades) {
      final value = _gradeValue(grade);
      if (value == null) continue;
      map.putIfAbsent(value.scale, () => []).add(value);
    }
    return map;
  }

  String? _normalizeGrade(String grade) {
    final cleaned = grade.trim();
    if (cleaned.isEmpty) return null;
    final firstToken = cleaned.split(RegExp(r'\s+')).first;
    final slashIndex = firstToken.indexOf('/');
    if (slashIndex != -1) {
      return firstToken.substring(0, slashIndex);
    }
    return firstToken;
  }

  _GradeValue? _gradeValue(String grade) {
    final ydsIndex = _GradeScales.yds.indexOf(grade);
    if (ydsIndex != -1) {
      return _GradeValue(scale: GradeScale.yds, index: ydsIndex, label: _GradeScales.yds[ydsIndex]);
    }
    final frenchIndex = _GradeScales.french.indexOf(grade);
    if (frenchIndex != -1) {
      return _GradeValue(scale: GradeScale.french, index: frenchIndex, label: _GradeScales.french[frenchIndex]);
    }
    final vIndex = _GradeScales.vScale.indexOf(grade);
    if (vIndex != -1) {
      return _GradeValue(scale: GradeScale.vScale, index: vIndex, label: _GradeScales.vScale[vIndex]);
    }
    return null;
  }

  static Map<String, List<String>> _buildRegionChildren(List<RegionNode> regions) {
    final map = <String, List<String>>{};
    for (final region in regions) {
      final key = region.parentId ?? 'root';
      map.putIfAbsent(key, () => []).add(region.id);
    }
    return map;
  }

  static Map<String, List<String>> _buildRegionCrags(List<Crag> crags) {
    final map = <String, List<String>>{};
    for (final crag in crags) {
      map.putIfAbsent(crag.regionId, () => []).add(crag.id);
    }
    return map;
  }

  static Map<String, List<String>> _buildCragWalls(List<Wall> walls, Map<String, Zone> zonesById) {
    final map = <String, List<String>>{};
    for (final wall in walls) {
      final cragId = wall.parentType == WallParentType.crag ? wall.parentId : zonesById[wall.parentId]?.cragId;
      if (cragId == null) continue;
      map.putIfAbsent(cragId, () => []).add(wall.id);
    }
    return map;
  }

  static Map<String, List<String>> _buildCragZones(List<Zone> zones) {
    final map = <String, List<String>>{};
    for (final zone in zones) {
      map.putIfAbsent(zone.cragId, () => []).add(zone.id);
    }
    return map;
  }

  static Map<String, List<String>> _buildZoneWalls(List<Wall> walls) {
    final map = <String, List<String>>{};
    for (final wall in walls) {
      if (wall.parentType != WallParentType.zone) continue;
      map.putIfAbsent(wall.parentId, () => []).add(wall.id);
    }
    return map;
  }

  static Map<String, String> _buildWallCrag(List<Wall> walls, Map<String, Zone> zonesById) {
    final map = <String, String>{};
    for (final wall in walls) {
      if (wall.parentType == WallParentType.crag) {
        map[wall.id] = wall.parentId;
      } else {
        final zone = zonesById[wall.parentId];
        if (zone != null) {
          map[wall.id] = zone.cragId;
        }
      }
    }
    return map;
  }

  static Map<String, List<String>> _buildWallRoutes(List<ClimbRoute> routes) {
    final map = <String, List<String>>{};
    for (final route in routes) {
      map.putIfAbsent(route.wallId, () => []).add(route.id);
    }
    return map;
  }
}

enum GradeScale { yds, french, vScale }

class _GradeValue {
  final GradeScale scale;
  final int index;
  final String label;

  const _GradeValue({required this.scale, required this.index, required this.label});
}

class _GradeScales {
  static const List<String> yds = [
    '<5.6',
    '5.6',
    '5.7',
    '5.8',
    '5.9',
    '5.10a',
    '5.10b',
    '5.10c',
    '5.10d',
    '5.11a',
    '5.11b',
    '5.11c',
    '5.11d',
    '5.12a',
    '5.12b',
    '5.12c',
    '5.12d',
    '5.13a',
    '5.13b',
    '5.13c',
    '5.13d',
    '5.14a',
    '5.14b',
    '5.14c',
    '5.14d',
    '5.15a',
    '5.15b',
    '5.15c',
    '5.15d',
  ];

  static const List<String> french = [
    '<4a',
    '4a',
    '4a+',
    '4b',
    '4b+',
    '4c',
    '4c+',
    '5a',
    '5a+',
    '5b',
    '5b+',
    '5c',
    '5c+',
    '6a',
    '6a+',
    '6b',
    '6b+',
    '6c',
    '6c+',
    '7a',
    '7a+',
    '7b',
    '7b+',
    '7c',
    '7c+',
    '8a',
    '8a+',
    '8b',
    '8b+',
    '8c',
    '8c+',
    '9a',
    '9a+',
    '9b',
    '9b+',
    '9c',
  ];

  static const List<String> vScale = [
    'VB',
    'V0',
    'V1',
    'V2',
    'V3',
    'V4',
    'V5',
    'V6',
    'V7',
    'V8',
    'V9',
    'V10',
    'V11',
    'V12',
    'V13',
    'V14',
    'V15',
    'V16',
    'V17',
  ];
}

class CragDataService {
  CragDataService._();

  static final CragDataService instance = CragDataService._();

  CragDataStore? _cache;

  Future<CragDataStore> load() async {
    if (_cache != null) return _cache!;

    final regionNodes = <RegionNode>[];
    final crags = <Crag>[];
    final zones = <Zone>[];
    final walls = <Wall>[];
    final routes = <ClimbRoute>[];

    final regionNameIndex = <String, String>{};
    final cragNameIndex = <String, Map<String, String>>{};

    int regionCounter = 0;
    int cragCounter = 0;
    int zoneCounter = 0;
    int wallCounter = 0;
    int routeCounter = 0;
    final wallRouteCounter = <String, int>{};

    final cragJson = jsonDecode(await rootBundle.loadString('resources/crags.json'));
    if (cragJson is List) {
      for (final raw in cragJson) {
        _parseCragNode(
          raw,
          parentRegionId: null,
          parentCragId: null,
          parentZoneId: null,
          parentWallId: null,
          regionNodes: regionNodes,
          crags: crags,
          zones: zones,
          walls: walls,
          routes: routes,
          regionNameIndex: regionNameIndex,
          cragNameIndex: cragNameIndex,
          regionCounter: () => 'r${regionCounter++}',
          cragCounter: () => 'c${cragCounter++}',
          zoneCounter: () => 'z${zoneCounter++}',
          wallCounter: () => 'w${wallCounter++}',
          routeCounter: () => 'route_${routeCounter++}',
          wallRouteCounter: wallRouteCounter,
        );
      }
    }

    final zonesById = {for (final zone in zones) zone.id: zone};
    final wallByCrag = <String, String>{};
    for (final wall in walls) {
      final cragId = wall.parentType == WallParentType.crag ? wall.parentId : zonesById[wall.parentId]?.cragId;
      if (cragId == null) continue;
      wallByCrag.putIfAbsent(cragId, () => wall.id);
    }

    final routesJson = jsonDecode(await rootBundle.loadString('resources/routes.json'));
    final regionsJson = routesJson is Map<String, dynamic> ? routesJson['thecrag_regions'] : null;
    if (regionsJson is List) {
      for (final rawRegion in regionsJson) {
        if (rawRegion is! Map<String, dynamic>) continue;
        final regionName = rawRegion['region_name'];
        if (regionName is! String || regionName.trim().isEmpty) continue;
        final regionId =
            regionNameIndex[regionName] ??
            _addRegion(
              name: regionName,
              parentId: null,
              regionNodes: regionNodes,
              regionNameIndex: regionNameIndex,
              regionCounter: () => 'r${regionCounter++}',
            );
        final cragList = rawRegion['thecrag_crags'];
        if (cragList is! List) continue;
        for (final rawCrag in cragList) {
          if (rawCrag is! Map<String, dynamic>) continue;
          final cragName = rawCrag['crag_name'];
          if (cragName is! String || cragName.trim().isEmpty) continue;
          final cragId =
              cragNameIndex[regionId]?[cragName] ??
              _addCrag(
                name: cragName,
                regionId: regionId,
                crags: crags,
                cragNameIndex: cragNameIndex,
                cragCounter: () => 'c${cragCounter++}',
              );
          final wallId =
              wallByCrag[cragId] ??
              _addDefaultWall(
                cragId: cragId,
                walls: walls,
                wallCounter: () => 'w${wallCounter++}',
                wallByCrag: wallByCrag,
              );
          final routeList = rawCrag['thecrag_routes'];
          if (routeList is! List) continue;
          int order = 1;
          for (final rawRoute in routeList) {
            if (rawRoute is! Map<String, dynamic>) continue;
            final routeName = rawRoute['route_name'];
            final routeGrade = rawRoute['route_grade'];
            if (routeName is! String || routeGrade is! String) continue;
            final typeValue = rawRoute['route_type'];
            final discipline = _parseDiscipline(typeValue is String ? typeValue : '');
            final quickdraws = rawRoute['quickdraw_count'];
            routes.add(
              ClimbRoute(
                id: 'route_${routeCounter++}',
                wallId: wallId,
                order: order++,
                name: routeName.trim(),
                grade: routeGrade.trim(),
                discipline: discipline,
                quickdraws: quickdraws is int ? quickdraws : null,
              ),
            );
          }
        }
      }
    }

    final relations = _buildRelations(regionNodes);

    _cache = CragDataStore(
      regions: regionNodes,
      relations: relations,
      crags: crags,
      zones: zones,
      walls: walls,
      routes: routes,
    );
    return _cache!;
  }

  static void _parseCragNode(
    dynamic raw, {
    required String? parentRegionId,
    required String? parentCragId,
    required String? parentZoneId,
    required String? parentWallId,
    required List<RegionNode> regionNodes,
    required List<Crag> crags,
    required List<Zone> zones,
    required List<Wall> walls,
    required List<ClimbRoute> routes,
    required Map<String, String> regionNameIndex,
    required Map<String, Map<String, String>> cragNameIndex,
    required String Function() regionCounter,
    required String Function() cragCounter,
    required String Function() zoneCounter,
    required String Function() wallCounter,
    required String Function() routeCounter,
    required Map<String, int> wallRouteCounter,
  }) {
    if (raw is! Map<String, dynamic>) return;
    final name = _readText(raw['title']) ?? _readText(raw['name']);
    if (name == null || name.isEmpty) return;
    final subtypeValue = _readText(raw['data_subtype']) ?? _readText(raw['subtype']) ?? '';
    final children = raw['children'];
    final childNodes = children is List ? children : const [];

    if (subtypeValue == 'region' || subtypeValue == 'area') {
      final regionId = regionCounter();
      final regionType = subtypeValue == 'area' ? RegionType.area : RegionType.region;
      regionNodes.add(RegionNode(id: regionId, name: name, parentId: parentRegionId, type: regionType));
      regionNameIndex.putIfAbsent(name, () => regionId);
      for (final child in childNodes) {
        _parseCragNode(
          child,
          parentRegionId: regionId,
          parentCragId: null,
          parentZoneId: null,
          parentWallId: null,
          regionNodes: regionNodes,
          crags: crags,
          zones: zones,
          walls: walls,
          routes: routes,
          regionNameIndex: regionNameIndex,
          cragNameIndex: cragNameIndex,
          regionCounter: regionCounter,
          cragCounter: cragCounter,
          zoneCounter: zoneCounter,
          wallCounter: wallCounter,
          routeCounter: routeCounter,
          wallRouteCounter: wallRouteCounter,
        );
      }
      return;
    }

    if (subtypeValue == 'crag') {
      final cragId = cragCounter();
      crags.add(Crag(id: cragId, regionId: parentRegionId ?? 'root', name: name));
      if (parentRegionId != null) {
        cragNameIndex.putIfAbsent(parentRegionId, () => {})[name] = cragId;
      }
      for (final child in childNodes) {
        _parseCragNode(
          child,
          parentRegionId: parentRegionId,
          parentCragId: cragId,
          parentZoneId: null,
          parentWallId: null,
          regionNodes: regionNodes,
          crags: crags,
          zones: zones,
          walls: walls,
          routes: routes,
          regionNameIndex: regionNameIndex,
          cragNameIndex: cragNameIndex,
          regionCounter: regionCounter,
          cragCounter: cragCounter,
          zoneCounter: zoneCounter,
          wallCounter: wallCounter,
          routeCounter: routeCounter,
          wallRouteCounter: wallRouteCounter,
        );
      }
      return;
    }

    if (subtypeValue == 'zone') {
      if (parentCragId == null) return;
      final zoneId = zoneCounter();
      zones.add(Zone(id: zoneId, cragId: parentCragId, name: name));
      for (final child in childNodes) {
        _parseCragNode(
          child,
          parentRegionId: parentRegionId,
          parentCragId: parentCragId,
          parentZoneId: zoneId,
          parentWallId: null,
          regionNodes: regionNodes,
          crags: crags,
          zones: zones,
          walls: walls,
          routes: routes,
          regionNameIndex: regionNameIndex,
          cragNameIndex: cragNameIndex,
          regionCounter: regionCounter,
          cragCounter: cragCounter,
          zoneCounter: zoneCounter,
          wallCounter: wallCounter,
          routeCounter: routeCounter,
          wallRouteCounter: wallRouteCounter,
        );
      }
      return;
    }

    if (subtypeValue == 'wall' || subtypeValue == 'bloc') {
      if (parentCragId == null) return;
      final wallId = wallCounter();
      final parentType = parentZoneId == null ? WallParentType.crag : WallParentType.zone;
      final parentId = parentZoneId ?? parentCragId;
      walls.add(
        Wall(
          id: wallId,
          parentId: parentId,
          parentType: parentType,
          name: name,
          type: subtypeValue == 'bloc' ? WallType.bloc : WallType.wall,
        ),
      );
      for (final child in childNodes) {
        _parseCragNode(
          child,
          parentRegionId: parentRegionId,
          parentCragId: parentCragId,
          parentZoneId: parentZoneId,
          parentWallId: wallId,
          regionNodes: regionNodes,
          crags: crags,
          zones: zones,
          walls: walls,
          routes: routes,
          regionNameIndex: regionNameIndex,
          cragNameIndex: cragNameIndex,
          regionCounter: regionCounter,
          cragCounter: cragCounter,
          zoneCounter: zoneCounter,
          wallCounter: wallCounter,
          routeCounter: routeCounter,
          wallRouteCounter: wallRouteCounter,
        );
      }
      return;
    }

    if (subtypeValue == 'route') {
      if (parentWallId == null) return;
      final order = (wallRouteCounter[parentWallId] ?? 0) + 1;
      wallRouteCounter[parentWallId] = order;
      final grade = _readText(raw['grade']) ?? _readText(raw['route_grade']) ?? '-';
      final discipline = _parseDiscipline(_readText(raw['discipline']) ?? _readText(raw['route_type']) ?? '');
      final bolts = _readInt(raw['bolt']) ?? _readInt(raw['bolts']) ?? _readInt(raw['quickdraw_count']);
      final pitches = _parsePitches(childNodes);
      routes.add(
        ClimbRoute(
          id: routeCounter(),
          wallId: parentWallId,
          order: order,
          name: name,
          grade: grade,
          discipline: discipline,
          quickdraws: bolts,
          isMultiPitch: pitches.isNotEmpty,
          pitches: pitches,
        ),
      );
      return;
    }
  }

  static String _addRegion({
    required String name,
    required String? parentId,
    required List<RegionNode> regionNodes,
    required Map<String, String> regionNameIndex,
    required String Function() regionCounter,
  }) {
    final regionId = regionCounter();
    regionNodes.add(RegionNode(id: regionId, name: name, parentId: parentId, type: RegionType.region));
    regionNameIndex[name] = regionId;
    return regionId;
  }

  static String _addCrag({
    required String name,
    required String regionId,
    required List<Crag> crags,
    required Map<String, Map<String, String>> cragNameIndex,
    required String Function() cragCounter,
  }) {
    final cragId = cragCounter();
    crags.add(Crag(id: cragId, regionId: regionId, name: name));
    cragNameIndex.putIfAbsent(regionId, () => {})[name] = cragId;
    return cragId;
  }

  static String _addDefaultWall({
    required String cragId,
    required List<Wall> walls,
    required String Function() wallCounter,
    required Map<String, String> wallByCrag,
  }) {
    final wallId = wallCounter();
    walls.add(Wall(id: wallId, parentId: cragId, parentType: WallParentType.crag, name: '主壁', type: WallType.wall));
    wallByCrag[cragId] = wallId;
    return wallId;
  }

  static String? _readText(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static List<RoutePitch> _parsePitches(List<dynamic> children) {
    final pitches = <RoutePitch>[];
    var order = 1;
    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      final subtype = _readText(child['data_subtype']) ?? _readText(child['subtype']) ?? '';
      if (subtype != 'pitch') continue;
      final grade = _readText(child['grade']) ?? _readText(child['route_grade']);
      final bolt = _readInt(child['bolt']) ?? _readInt(child['bolts']) ?? _readInt(child['quickdraw_count']);
      pitches.add(RoutePitch(order: order++, grade: grade, bolt: bolt));
    }
    return pitches;
  }

  static List<RegionRelation> _buildRelations(List<RegionNode> regions) {
    final relations = <RegionRelation>[];
    final byId = {for (final region in regions) region.id: region};
    for (final region in regions) {
      relations.add(RegionRelation(ancestorId: region.id, descendantId: region.id, depth: 0));
      var depth = 1;
      var current = region;
      while (current.parentId != null) {
        final parent = byId[current.parentId!];
        if (parent == null) break;
        relations.add(RegionRelation(ancestorId: parent.id, descendantId: region.id, depth: depth));
        depth += 1;
        current = parent;
      }
    }
    return relations;
  }

  static List<RegionRelation> buildRelations(List<RegionNode> regions) {
    return _buildRelations(regions);
  }

  static RouteDiscipline _parseDiscipline(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('trad')) return RouteDiscipline.trad;
    if (value.contains('boulder')) return RouteDiscipline.bouldering;
    if (value.contains('dws')) return RouteDiscipline.deepWaterSolo;
    return RouteDiscipline.sport;
  }
}
