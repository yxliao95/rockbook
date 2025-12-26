import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rockbook/src/provider/crags_provider.dart';
import 'package:rockbook/src/provider/routes_provider.dart';
import 'package:rockbook/src/services/crag_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = await CragDataService.instance.load();

  debugPrint('regions: ${store.regions.length}');
  debugPrint('relations: ${store.relations.length}');
  debugPrint('crags: ${store.crags.length}');
  debugPrint('walls: ${store.walls.length}');
  debugPrint('routes: ${store.routes.length}');

  // 额外 sanity checks
  final roots = store.rootRegions();
  debugPrint('rootRegions: ${roots.length}');
  if (roots.isNotEmpty) {
    final r0 = roots.first;
    debugPrint('first root: ${r0.id} ${r0.name} type=${r0.type}');
    final children = store.childRegions(r0.id);
    debugPrint('children of first root: ${children.length}');
    final crags = store.cragsByRegion(r0.id);
    debugPrint('crags in first root region: ${crags.length}');
  }

  // // 如果你想看某个具体 region 的 path
  // if (store.regions.isNotEmpty) {
  //   final anyRegionId = store.regions.first.id;
  //   debugPrint('regionPath(${anyRegionId}) = ${store.regionPath(anyRegionId)}');
  // }

  runApp(const _DebugApp());
}

class _DebugApp extends StatelessWidget {
  const _DebugApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('CragDataService loaded. Check console output.'))),
    );
  }
}
