import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/region_model.dart';
import '../models/route_model.dart';
import '../provider/crags_provider.dart';

class RouteFilterState {
  final Set<String> selectedCragIds;
  final Set<String> grades;
  final Set<String> types;
  final Set<String> styles;
  final Set<int> quickdraws;

  const RouteFilterState({
    this.selectedCragIds = const <String>{},
    this.grades = const <String>{},
    this.types = const <String>{},
    this.styles = const <String>{},
    this.quickdraws = const <int>{},
  });

  RouteFilterState copyWith({
    Set<String>? selectedCragIds,
    Set<String>? grades,
    Set<String>? types,
    Set<String>? styles,
    Set<int>? quickdraws,
  }) {
    return RouteFilterState(
      selectedCragIds: selectedCragIds ?? this.selectedCragIds,
      grades: grades ?? this.grades,
      types: types ?? this.types,
      styles: styles ?? this.styles,
      quickdraws: quickdraws ?? this.quickdraws,
    );
  }
}

class RoutesFilterNotifier extends Notifier<RouteFilterState> {
  @override
  RouteFilterState build() => const RouteFilterState();

  void toggleCrag(String cragId) {
    final next = Set<String>.from(state.selectedCragIds);
    if (!next.add(cragId)) {
      next.remove(cragId);
    }
    state = state.copyWith(selectedCragIds: next);
  }

  void clearCrags() => state = state.copyWith(selectedCragIds: const <String>{});

  void toggleGrade(String grade) {
    final next = Set<String>.from(state.grades);
    if (!next.add(grade)) {
      next.remove(grade);
    }
    state = state.copyWith(grades: next);
  }

  void toggleType(String type) {
    final next = Set<String>.from(state.types);
    if (!next.add(type)) {
      next.remove(type);
    }
    state = state.copyWith(types: next);
  }

  void toggleStyle(String style) {
    final next = Set<String>.from(state.styles);
    if (!next.add(style)) {
      next.remove(style);
    }
    state = state.copyWith(styles: next);
  }

  void toggleQuickdraws(int count) {
    final next = Set<int>.from(state.quickdraws);
    if (!next.add(count)) {
      next.remove(count);
    }
    state = state.copyWith(quickdraws: next);
  }

  void clearFilters() {
    state = state.copyWith(
      grades: const <String>{},
      types: const <String>{},
      styles: const <String>{},
      quickdraws: const <int>{},
    );
  }
}

final routesFilterProvider = NotifierProvider<RoutesFilterNotifier, RouteFilterState>(RoutesFilterNotifier.new);

final allRoutesProvider = Provider<List<ClimbRoute>>((ref) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.routes ?? const [];
});

final routeByIdProvider = Provider.family<ClimbRoute?, String>((ref, routeId) {
  final matches = ref.watch(allRoutesProvider).where((route) => route.id == routeId);
  return matches.isEmpty ? null : matches.first;
});

final filteredRoutesProvider = Provider<List<ClimbRoute>>((ref) {
  final state = ref.watch(routesFilterProvider);
  final routes = ref.watch(allRoutesProvider);
  final data = ref.watch(cragDataProvider).asData?.value;

  return routes.where((route) {
    final cragId = data?.cragIdForRoute(route);
    if (state.selectedCragIds.isNotEmpty && (cragId == null || !state.selectedCragIds.contains(cragId))) {
      return false;
    }
    if (state.grades.isNotEmpty && !state.grades.contains(route.grade)) {
      return false;
    }
    if (state.types.isNotEmpty && !state.types.contains(route.discipline.label)) {
      return false;
    }
    if (state.styles.isNotEmpty && !state.styles.contains(route.style ?? '')) {
      return false;
    }
    if (state.quickdraws.isNotEmpty && !state.quickdraws.contains(route.quickdraws ?? -1)) {
      return false;
    }
    return true;
  }).toList();
});

class RouteFilterOptions {
  final List<String> grades;
  final List<String> types;
  final List<String> styles;
  final List<int> quickdraws;

  const RouteFilterOptions({
    required this.grades,
    required this.types,
    required this.styles,
    required this.quickdraws,
  });
}

final routeFilterOptionsProvider = Provider<RouteFilterOptions>((ref) {
  final routes = ref.watch(allRoutesProvider);
  final grades = routes.map((route) => route.grade).toSet().toList()..sort();
  final types = routes.map((route) => route.discipline.label).toSet().toList()..sort();
  final styles = routes.map((route) => route.style).whereType<String>().toSet().toList()..sort();
  final quickdraws = routes.map((route) => route.quickdraws).whereType<int>().toSet().toList()..sort();

  return RouteFilterOptions(grades: grades, types: types, styles: styles, quickdraws: quickdraws);
});

class CragRouteGroup {
  final Crag crag;
  final List<ClimbRoute> routes;

  const CragRouteGroup({required this.crag, required this.routes});
}

class RegionRouteGroup {
  final String title;
  final List<CragRouteGroup> crags;

  const RegionRouteGroup({required this.title, required this.crags});
}

final routeGroupsProvider = Provider<List<RegionRouteGroup>>((ref) {
  final data = ref.watch(cragDataProvider).asData?.value;
  if (data == null) return const [];
  final routes = ref.watch(filteredRoutesProvider);
  final groups = <RegionRouteGroup>[];

  for (final region in data.regions) {
    final crags = data.cragsByRegion(region.id);
    if (crags.isEmpty) continue;
    final cragGroups = <CragRouteGroup>[];

    for (final crag in crags) {
      final cragRoutes = routes.where((route) => data.cragIdForRoute(route) == crag.id).toList();
      if (cragRoutes.isEmpty) continue;
      cragGroups.add(CragRouteGroup(crag: crag, routes: cragRoutes));
    }

    if (cragGroups.isEmpty) continue;
    groups.add(RegionRouteGroup(title: data.regionPath(region.id), crags: cragGroups));
  }

  return groups;
});
