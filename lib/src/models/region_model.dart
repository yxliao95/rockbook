enum RegionType {
  region,
  area,
}

class RegionNode {
  final String id;
  final String name;
  final String? parentId;
  final RegionType type;

  const RegionNode({
    required this.id,
    required this.name,
    required this.parentId,
    required this.type,
  });

  RegionNode copyWith({String? id, String? name, String? parentId, RegionType? type}) {
    return RegionNode(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
    );
  }
}

class RegionRelation {
  final String ancestorId;
  final String descendantId;
  final int depth;

  const RegionRelation({required this.ancestorId, required this.descendantId, required this.depth});
}

class RegionChildren {
  final List<RegionNode> regions;
  final List<Crag> crags;

  const RegionChildren({required this.regions, required this.crags});

  const RegionChildren.empty() : regions = const [], crags = const [];
}

class GradeSummary {
  final int routeCount;
  final String gradeRange;

  const GradeSummary({required this.routeCount, required this.gradeRange});

  const GradeSummary.empty() : routeCount = 0, gradeRange = '-';
}

enum WallType { cliff, boulder }

class Wall {
  final String id;
  final String cragId;
  final String name;
  final WallType type;
  final String? panoramaImage;
  final String? approachDescription;

  const Wall({
    required this.id,
    required this.cragId,
    required this.name,
    required this.type,
    this.panoramaImage,
    this.approachDescription,
  });
}

class GradeCount {
  final String grade;
  final int count;

  const GradeCount({required this.grade, required this.count});
}

class Crag {
  final String id;
  final String regionId;
  final String name;
  final String? rockType;
  final String? approachTime;
  final String? exposure;
  final String? approachMethod;
  final String? parking;
  final String? mainEntrance;
  final String? recommendedApproach;
  final String? wallOverview;
  final String? overviewImage;
  final List<String> wallImages;
  final String? mapImage;
  final String? weatherSummary;

  const Crag({
    required this.id,
    required this.regionId,
    required this.name,
    this.rockType,
    this.approachTime,
    this.exposure,
    this.approachMethod,
    this.parking,
    this.mainEntrance,
    this.recommendedApproach,
    this.wallOverview,
    this.overviewImage,
    this.wallImages = const [],
    this.mapImage,
    this.weatherSummary,
  });
}
