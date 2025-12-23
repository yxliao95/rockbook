import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_state_model.dart';

// 含义：注册一个 NotifierProvider，内部创建 AppStateNotifier AppStateNotifier.new），对外暴露的状态类型是 AppStateModel。
// AppStateNotifier 继承 Notifier<AppStateModel>，其 build() 返回初始 AppStateModel。之后通过 state = state.copyWith(...) 更新。
// 使用：
// 读状态并订阅重建：ref.watch(appStateProvider) -> AppStateModel
// 写状态：ref.read(appStateProvider.notifier).setTabTo(…)/selectGym(…)
final appStateProvider = NotifierProvider<AppStateNotifier, AppStateModel>(AppStateNotifier.new);

// 直接 watch 整个 appStateProvider, 组件会在 AppStateModel 的任意字段变化时重建
// 如果只关心某个字段，可以单独创建一个 Provider 来 watch 该字段，避免不必要的重建
// 含义：定义一个派生 Provider<int>。它内部 watch 了 appStateProvider，但只取出 currentTabIndex 字段。
// 作用：让 UI 只在 currentTabIndex 变化时重建，避免 AppStateModel 其他字段变化引发的无关重建。
// 使用：ref.watch(currentTabIndexProvider) -> int
// 等价的更简写写法（不单独定义派生 Provider，也能达到“只监听某字段”的效果）：
// final index = ref.watch(appStateProvider.select((s) => s.currentTabIndex));
final currentTabIndexProvider = Provider<int>((ref) => ref.watch(appStateProvider).currentTabIndex);

/// 全局应用状态
/// 用户在应用中的状态
class AppStateNotifier extends Notifier<AppStateModel> {
  // Notifier 是 Riverpod 的概念性接口
  // state 的类型就是 AppStateModel。Notifier 的 state 是同步值；AsyncNotifier 的 state 是 AsyncValue<T>。
  // 初始值由 build() 返回：build() 首次运行后，state 即为该返回值。
  // 给 state 赋值会通知所有 watch 了这个 provider 的监听者，触发重建。
  // 在构造函数里不能用 state；应在 build() 或方法里读/写 state。

  @override
  AppStateModel build() => const AppStateModel();

  void setTabTo(int index) {
    if (state.currentTabIndex == index) return;
    state = state.copyWith(currentTabIndex: index);
  }
}
