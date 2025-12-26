import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/crags_provider.dart';
import '../../provider/routes_provider.dart';
import '../common/route_log_dialog.dart';

/// 线路页面示例
class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(routeGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('线路')),
      body: Column(
        children: [
          const _RoutesToolbar(),
          Expanded(
            child: groups.isEmpty
                ? const Center(child: Text('暂无符合条件的线路'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: _buildRouteSections(context, groups),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteSections(BuildContext context, List<RegionRouteGroup> groups) {
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
