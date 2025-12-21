import 'package:flutter/foundation.dart';

/// 应用的全局状态模型
/// @immutable + final 字段保证对象一旦创建不可修改。
/// copyWith 提供安全的“生成新状态”的方法。
/// 在 Flutter 状态管理（特别是 Riverpod/Bloc）里，这是推荐的最佳实践。
@immutable
class AppStateModel {
  final String? selectedGymId;
  final int currentTabIndex;

  const AppStateModel({this.selectedGymId = 'g1', this.currentTabIndex = 0});

  AppStateModel copyWith({String? selectedGymId, int? currentTabIndex}) {
    return AppStateModel(
      selectedGymId: selectedGymId ?? this.selectedGymId,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}
