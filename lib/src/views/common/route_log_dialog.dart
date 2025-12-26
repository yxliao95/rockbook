import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/route_log_model.dart';
import '../../models/route_model.dart';
import '../../provider/logbook_provider.dart';
import '../../models/user_model.dart';
import '../../provider/user_provider.dart';

class RouteLogDialog extends ConsumerStatefulWidget {
  final ClimbRoute route;
  final RouteLog? initialLog;

  const RouteLogDialog({super.key, required this.route, this.initialLog});

  @override
  ConsumerState<RouteLogDialog> createState() => _RouteLogDialogState();
}

class _RouteLogDialogState extends ConsumerState<RouteLogDialog> {
  late DateTime _dateTime;
  late ClimbType _climbType;
  late AscentType _ascentType;
  late TextEditingController _belayerController;
  String? _belayerUserId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLog;
    _dateTime = initial?.dateTime ?? DateTime.now();
    _climbType = initial?.climbType ?? _defaultClimbType();
    _ascentType = initial?.ascentType ?? AscentType.onsight;
    _belayerController = TextEditingController(text: initial?.belayerName ?? '');
    _belayerUserId = initial?.belayerUserId;
  }

  @override
  void dispose() {
    _belayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(allUsersProvider);

    return AlertDialog(
      title: Text('记录 ${widget.route.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('时间'),
              subtitle: Text(_formatDateTime(_dateTime)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            _DropdownField<ClimbType>(
              label: '类型',
              value: _climbType,
              items: ClimbType.values,
              labelBuilder: (value) => value.label,
              onChanged: (value) => setState(() => _climbType = value),
            ),
            const SizedBox(height: 8),
            _DropdownField<AscentType>(
              label: '完成情况',
              value: _ascentType,
              items: AscentType.values,
              labelBuilder: (value) => value.label,
              onChanged: (value) => setState(() => _ascentType = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _belayerController,
              decoration: const InputDecoration(
                labelText: '保护员',
                hintText: '输入昵称自动搜索，可直接填写姓名',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _belayerUserId = null),
            ),
            if (_belayerController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(spacing: 8, runSpacing: 8, children: _buildBelayerSuggestions(users)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        FilledButton(onPressed: _saveLog, child: const Text('保存')),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (!mounted || time == null) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveLog() {
    final notifier = ref.read(routeLogsProvider.notifier);
    final existing = widget.initialLog;
    final log = (existing ?? _newLog()).copyWith(
      dateTime: _dateTime,
      climbType: _climbType,
      ascentType: _ascentType,
      belayerName: _belayerController.text.trim().isEmpty ? null : _belayerController.text.trim(),
      belayerUserId: _belayerUserId,
    );
    if (existing == null) {
      notifier.addLog(log);
    } else {
      notifier.updateLog(log);
    }
    Navigator.of(context).pop();
  }

  RouteLog _newLog() {
    final user = ref.read(currentUserProvider);
    return RouteLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      routeId: widget.route.id,
      userId: user?.id ?? 'unknown',
      dateTime: _dateTime,
      climbType: _climbType,
      ascentType: _ascentType,
    );
  }

  ClimbType _defaultClimbType() {
    if (widget.route.discipline == RouteDiscipline.bouldering) {
      return ClimbType.bouldering;
    }
    return ClimbType.lead;
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
  }

  List<Widget> _buildBelayerSuggestions(List<AppUser> users) {
    final query = _belayerController.text.trim();
    final matches = users.where((user) => user.nickname.contains(query)).take(5).toList(growable: false);
    if (matches.isEmpty) {
      return const [Text('未找到匹配的昵称')];
    }
    return matches
        .map(
          (user) => ChoiceChip(
            label: Text(user.nickname),
            selected: _belayerUserId == user.id,
            onSelected: (_) {
              setState(() {
                _belayerController.text = user.nickname;
                _belayerUserId = user.id;
              });
            },
          ),
        )
        .toList();
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(labelBuilder(item)))).toList(),
          onChanged: (value) {
            if (value == null) return;
            onChanged(value);
          },
        ),
      ),
    );
  }
}
