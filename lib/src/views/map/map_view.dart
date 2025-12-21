import 'package:flutter/material.dart';

/// 岩馆页面示例
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('地图', style: Theme.of(context).textTheme.headlineMedium));
  }
}
