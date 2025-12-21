import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crag_model.dart';
import '../../provider/crags_provider.dart';
import 'region_crags_view.dart';

/// 岩场页面示例
class CragsPage extends ConsumerWidget {
  const CragsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinces = ref.watch(provincesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('岩场')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provinces.length,
        itemBuilder: (context, index) {
          final province = provinces[index];
          final regions = ref.watch(regionsByProvinceProvider(province.id));

          return Card(
            child: ExpansionTile(
              title: Text(province.name, style: Theme.of(context).textTheme.titleMedium),
              children: regions
                  .map(
                    (region) => ListTile(
                      title: Text(region.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (context) => RegionCragsPage(region: region)));
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
