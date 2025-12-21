import 'zone_model.dart';

class Gym {
  final String id;

  // 顶部简介
  final String name;
  final String subTitle;
  final String? logoUrl;

  // 公告
  final List<String>? announcements;

  // 可用的设施
  final List<String>? facilities;

  final List<Zone> zones;

  const Gym({
    required this.id,
    required this.name,
    this.subTitle = '',
    this.logoUrl,
    this.announcements,
    this.facilities,
    this.zones = const [],
  });
}
