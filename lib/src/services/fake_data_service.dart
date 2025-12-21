import '../models/gym_model.dart';
import '../models/zone_model.dart';
import '../models/user_model.dart';

/// 简单的内存数据源（同步、无异步）。
class FakeDataService {
  FakeDataService._(); // 私有构造函数
  /// 单例
  static final instance = FakeDataService._();

  final List<Gym> _gyms = const [
    Gym(
      id: 'g1',
      name: '香蕉攀岩',
      subTitle: '深圳宝安店',
      announcements: [
        '2023-10-01 新增线路公告:\n V0: 5条\n V1: 5条\n V2: 4条\n V3: 3条\n V4: 2条\n V5: 1条',
        '2023-08-01 新增线路公告:\n V0: 5条\n V1: 5条\n V2: 4条\n V3: 3条\n V4: 2条\n V5: 1条',
      ],
      zones: [
        Zone(id: 'g1-z1', name: 'Zone A', type: ZoneType.bouldering, svgUrl: 'assets/gym_map.svg'),
        Zone(id: 'g1-z2', name: 'Zone B', type: ZoneType.bouldering, svgUrl: 'assets/gym_map.svg'),
        Zone(id: 'g1-z3', name: 'Zone C', type: ZoneType.bouldering, svgUrl: 'assets/gym_map.svg'),
        Zone(id: 'g1-z4', name: 'Zone D', type: ZoneType.ropedClimbing, svgUrl: 'assets/gym_map.svg'),
      ],
      facilities: ['Cafe', 'Shop', 'Rental'],
    ),
    Gym(
      id: 'g2',
      name: 'Cube有石',
      subTitle: '1.0',
      zones: [
        Zone(id: 'g2-z1', name: 'Zone A', type: ZoneType.bouldering, svgUrl: 'assets/gym_map.svg'),
        Zone(id: 'g2-z2', name: 'Zone B', type: ZoneType.bouldering, svgUrl: 'assets/gym_map.svg'),
        Zone(id: 'g2-z3', name: 'Zone C', type: ZoneType.ropedClimbing, svgUrl: 'assets/gym_map.svg'),
      ],
      facilities: ['Cafe', 'Shop'],
    ),
  ];

  final UserProfile _currentUser = const UserProfile(id: 'u-001', displayName: 'mida');

  // API
  List<Gym> getGyms() => List.unmodifiable(_gyms);
  UserProfile getCurrentUser() => _currentUser;
  Gym? getGymById(String id) => _gyms.where((g) => g.id == id).firstOrNull;
}

// 小扩展：firstOrNull
extension _IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
