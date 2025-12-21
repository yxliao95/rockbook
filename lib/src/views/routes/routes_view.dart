import 'package:flutter/material.dart';

/// 岩馆页面示例
class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('线路列表', style: Theme.of(context).textTheme.headlineMedium));
  }
}
