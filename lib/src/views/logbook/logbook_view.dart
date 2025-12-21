import 'package:flutter/material.dart';

/// 岩馆页面示例
class LogbookPage extends StatelessWidget {
  const LogbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('记录', style: Theme.of(context).textTheme.headlineMedium));
  }
}
