import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/app_state_provider.dart';
import 'views/crags/crags_view.dart';
import 'views/logbook/logbook_view.dart';
import 'views/routes/routes_view.dart';
import 'views/map/map_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ← 添加 const 关键字

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rockbook',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.dark),
      ),
      home: MainPage(),
    );
  }
}

// 将 StatefulWidget 改为 Riverpod 的 ConsumerWidget，其中的 build 方法多了一个 WidgetRef 参数
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  static const List<Widget> _pages = <Widget>[
    CragsPage(), // 岩场页面
    RoutesPage(), // 线路页面
    LogbookPage(), // 记录页面
    MapPage(), // 地图页面
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final currentTabIndex = ref.watch(currentTabIndexProvider); // 监听 currentTabIndexProvider

    // Scaffold 是一个包含多个常见区域（顶部、底部、浮动按钮等）的容器。
    return Scaffold(
      body: IndexedStack(index: currentTabIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 65,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.landscape, color: theme.colorScheme.onSecondary),
            icon: Icon(Icons.landscape),
            label: '岩场',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.route, color: theme.colorScheme.onSecondary),
            icon: Icon(Icons.route),
            label: '线路',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.edit_note, color: theme.colorScheme.onSecondary),
            icon: Icon(Icons.edit_note),
            label: '记录',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map, color: theme.colorScheme.onSecondary),
            icon: Icon(Icons.map),
            label: '地图',
          ),
        ],
        indicatorColor: theme.colorScheme.secondary,
        selectedIndex: currentTabIndex,
        onDestinationSelected: (int index) {
          ref.read(appStateProvider.notifier).setTabTo(index); // 通过 appStateProvider 的 notifier 调用 setTab 方法
        },
        animationDuration: const Duration(milliseconds: 0),
        overlayColor: WidgetStateProperty.all(Colors.transparent), // 移除点击时的透明波纹
      ),
    );
  }
}
