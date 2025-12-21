class Province {
  final String id;
  final String name;

  const Province({required this.id, required this.name});
}

class Region {
  final String id;
  final String provinceId;
  final String name;

  const Region({required this.id, required this.provinceId, required this.name});
}

class CragSummary {
  final String id;
  final String regionId;
  final String name;
  final int routeCount;
  final String gradeRange;
  final int ascents;

  const CragSummary({
    required this.id,
    required this.regionId,
    required this.name,
    required this.routeCount,
    required this.gradeRange,
    required this.ascents,
  });
}

class GradeCount {
  final String grade;
  final int count;

  const GradeCount({required this.grade, required this.count});
}

class CragDetail {
  final String id;
  final String name;
  final String rockType;
  final String approachTime;
  final String exposure;
  final String approachMethod;
  final String parking;
  final String wallType;
  final int routeCount;
  final String gradeRange;
  final List<GradeCount> gradeDistribution;
  final String overviewImage;
  final List<String> wallImages;
  final String mapImage;
  final String weatherSummary;

  const CragDetail({
    required this.id,
    required this.name,
    required this.rockType,
    required this.approachTime,
    required this.exposure,
    required this.approachMethod,
    required this.parking,
    required this.wallType,
    required this.routeCount,
    required this.gradeRange,
    required this.gradeDistribution,
    required this.overviewImage,
    required this.wallImages,
    required this.mapImage,
    required this.weatherSummary,
  });
}
