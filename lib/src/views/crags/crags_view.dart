import 'package:flutter/material.dart';

/// 岩馆页面示例
class CragsPage extends StatelessWidget {
  const CragsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('岩场列表', style: Theme.of(context).textTheme.headlineMedium));
  }
}
