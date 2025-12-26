import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/auth_helpers.dart';
import '../common/comment_section.dart';
import '../common/page_action_helpers.dart';

/// 岩馆页面示例
class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt_outlined),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showPageUpdateDialog(
                context: context,
                ref: ref,
                pageId: 'page:map',
                pageName: '地图',
                scopeKeys: const ['scope:map'],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              if (!requireLogin(context, ref)) return;
              showHistoryDialog(context: context, ref: ref, title: '地图', scopeKeys: const ['scope:map']);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Text('地图', style: Theme.of(context).textTheme.headlineMedium)),
          CommentSection(targetKey: 'page:map'),
        ],
      ),
    );
  }
}
