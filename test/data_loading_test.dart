import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rockbook/src/provider/crags_provider.dart';
import 'package:rockbook/src/provider/routes_provider.dart';
import 'package:rockbook/src/services/crag_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CragDataService loads data and builds relations', () async {
    final store = await CragDataService.instance.load();

    expect(store.regions, isNotEmpty);
    expect(store.crags, isNotEmpty);
    expect(store.zones, isNotEmpty);
    expect(store.walls, isNotEmpty);
    expect(store.routes, isNotEmpty);

    final region = store.regions.first;
    expect(store.regionPath(region.id).contains(region.name), isTrue);

    for (final route in store.routes) {
      final cragId = store.cragIdForRoute(route);
      expect(cragId, isNotNull);
      expect(store.cragById(cragId!), isNotNull);
      expect(store.wallById(route.wallId), isNotNull);
    }
  });

  test('Providers expose loaded routes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final store = await container.read(cragDataProvider.future);
    final routes = container.read(allRoutesProvider);

    expect(routes, isNotEmpty);
    expect(routes.length, store.routes.length);
  });
}
