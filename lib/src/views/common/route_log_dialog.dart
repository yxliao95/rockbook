import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/route_log_model.dart';
import '../../models/route_model.dart';
import '../../provider/logbook_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLog;
    _dateTime = initial?.dateTime ?? DateTime.now();
    _climbType = initial?.climbType ?? ClimbType.lead;
    _ascentType = initial?.ascentType ?? AscentType.onsight;
  }

  @override
  Widget build(BuildContext context) {
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
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time == null) return;
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
    );
    if (existing == null) {
      notifier.addLog(log);
    } else {
      notifier.updateLog(log);
    }
    Navigator.of(context).pop();
  }

  RouteLog _newLog() {
    return RouteLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      routeId: widget.route.id,
      dateTime: _dateTime,
      climbType: _climbType,
      ascentType: _ascentType,
    );
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
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
