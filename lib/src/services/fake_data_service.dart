import '../models/crag_model.dart';
import '../models/route_model.dart';

/// 简单的内存数据源（同步、无异步）。
class FakeDataService {
  FakeDataService._(); // 私有构造函数
  /// 单例
  static final instance = FakeDataService._();

  final List<Province> _provinces = const [Province(id: 'p-gd', name: '广东'), Province(id: 'p-gx', name: '广西')];

  final List<Region> _regions = const [
    Region(id: 'r-gd-qy', provinceId: 'p-gd', name: '清远英西'),
    Region(id: 'r-gx-ys', provinceId: 'p-gx', name: '阳朔'),
  ];

  final List<CragSummary> _crags = const [
    CragSummary(
      id: 'c-damiao',
      regionId: 'r-gd-qy',
      name: '大庙',
      routeCount: 68,
      gradeRange: '5.7 - 5.13a',
      ascents: 214,
    ),
    CragSummary(
      id: 'c-leipi',
      regionId: 'r-gx-ys',
      name: '雷劈山',
      routeCount: 45,
      gradeRange: '5.8 - 5.13c',
      ascents: 168,
    ),
  ];

  final List<CragDetail> _cragDetails = const [
    CragDetail(
      id: 'c-damiao',
      name: '大庙',
      rockType: '石灰岩',
      approachTime: '30分钟',
      exposure: '东南向',
      approachMethod: '村道步行+山路小径',
      parking: '大庙村口停车场',
      wallType: '陡峭主壁+缓坡侧壁',
      routeCount: 68,
      gradeRange: '5.7 - 5.13a',
      gradeDistribution: [
        GradeCount(grade: '5.7-5.9', count: 18),
        GradeCount(grade: '5.10', count: 22),
        GradeCount(grade: '5.11', count: 16),
        GradeCount(grade: '5.12+', count: 12),
      ],
      overviewImage: 'assets/crags/damiao_overview.png',
      wallImages: ['assets/crags/damiao_wall_1.png', 'assets/crags/damiao_wall_2.png'],
      mapImage: 'assets/crags/damiao_map.png',
      weatherSummary: '多云转晴，22-28°C，东南风2-3级',
    ),
    CragDetail(
      id: 'c-leipi',
      name: '雷劈山',
      rockType: '石灰岩',
      approachTime: '15分钟',
      exposure: '西南向',
      approachMethod: '景区步道',
      parking: '雷劈山景区停车场',
      wallType: '长线路壁+树荫区',
      routeCount: 45,
      gradeRange: '5.8 - 5.13c',
      gradeDistribution: [
        GradeCount(grade: '5.8-5.10', count: 16),
        GradeCount(grade: '5.11', count: 14),
        GradeCount(grade: '5.12', count: 9),
        GradeCount(grade: '5.13+', count: 6),
      ],
      overviewImage: 'assets/crags/leipi_overview.png',
      wallImages: ['assets/crags/leipi_wall_1.png', 'assets/crags/leipi_wall_2.png', 'assets/crags/leipi_wall_3.png'],
      mapImage: 'assets/crags/leipi_map.png',
      weatherSummary: '晴，24-31°C，南风1-2级',
    ),
  ];

  final List<ClimbRoute> _routes = const [
    ClimbRoute(
      id: 'r-damiao-1',
      cragId: 'c-damiao',
      name: '石门初见',
      grade: '5.9',
      type: '运动',
      style: '垂壁',
      quickdraws: 10,
    ),
    ClimbRoute(
      id: 'r-damiao-2',
      cragId: 'c-damiao',
      name: '寺顶风',
      grade: '5.10b',
      type: '运动',
      style: '缓坡',
      quickdraws: 12,
    ),
    ClimbRoute(
      id: 'r-damiao-3',
      cragId: 'c-damiao',
      name: '石狮路',
      grade: '5.11c',
      type: '运动',
      style: '陡峭',
      quickdraws: 14,
    ),
    ClimbRoute(
      id: 'r-leipi-1',
      cragId: 'c-leipi',
      name: '雷声',
      grade: '5.10a',
      type: '运动',
      style: '垂壁',
      quickdraws: 9,
    ),
    ClimbRoute(
      id: 'r-leipi-2',
      cragId: 'c-leipi',
      name: '霹雳线',
      grade: '5.11b',
      type: '运动',
      style: '陡峭',
      quickdraws: 13,
    ),
    ClimbRoute(
      id: 'r-leipi-3',
      cragId: 'c-leipi',
      name: '雨后',
      grade: '5.12a',
      type: '运动',
      style: '缓坡',
      quickdraws: 15,
    ),
  ];

  // API
  List<Province> getProvinces() => List.unmodifiable(_provinces);
  List<Region> getRegionsByProvince(String provinceId) =>
      List.unmodifiable(_regions.where((region) => region.provinceId == provinceId));
  List<CragSummary> getCragsByRegion(String regionId) =>
      List.unmodifiable(_crags.where((crag) => crag.regionId == regionId));
  CragSummary? getCragById(String id) => _crags.where((crag) => crag.id == id).firstOrNull;
  CragDetail? getCragDetailById(String id) => _cragDetails.where((detail) => detail.id == id).firstOrNull;
  List<ClimbRoute> getRoutes() => List.unmodifiable(_routes);
}

// 小扩展：firstOrNull
extension _IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
