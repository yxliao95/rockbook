enum RouteDiscipline {
  sport,
  trad,
  bouldering,
  deepWaterSolo,
}

extension RouteDisciplineLabel on RouteDiscipline {
  String get label {
    switch (this) {
      case RouteDiscipline.sport:
        return '运动攀';
      case RouteDiscipline.trad:
        return '传统攀';
      case RouteDiscipline.bouldering:
        return '抱石';
      case RouteDiscipline.deepWaterSolo:
        return '深水抱石';
    }
  }
}

class RoutePitch {
  final int order;
  final int? lengthMeters;
  final int? quickdraws;
  final String? grade;

  const RoutePitch({required this.order, this.lengthMeters, this.quickdraws, this.grade});
}

class ClimbRoute {
  final String id;
  final String cragId;
  final String wallId;
  final int order;
  final String name;
  final String grade;
  final RouteDiscipline discipline;
  final int? quickdraws;
  final int? heightMeters;
  final String? style;
  final String? description;
  final String? setter;
  final String? firstAscent;
  final bool isMultiPitch;
  final List<RoutePitch> pitches;

  const ClimbRoute({
    required this.id,
    required this.cragId,
    required this.wallId,
    required this.order,
    required this.name,
    required this.grade,
    required this.discipline,
    this.quickdraws,
    this.heightMeters,
    this.style,
    this.description,
    this.setter,
    this.firstAscent,
    this.isMultiPitch = false,
    this.pitches = const [],
  });

  ClimbRoute copyWith({
    String? id,
    String? cragId,
    String? wallId,
    int? order,
    String? name,
    String? grade,
    RouteDiscipline? discipline,
    int? quickdraws,
    int? heightMeters,
    String? style,
    String? description,
    String? setter,
    String? firstAscent,
    bool? isMultiPitch,
    List<RoutePitch>? pitches,
  }) {
    return ClimbRoute(
      id: id ?? this.id,
      cragId: cragId ?? this.cragId,
      wallId: wallId ?? this.wallId,
      order: order ?? this.order,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      discipline: discipline ?? this.discipline,
      quickdraws: quickdraws ?? this.quickdraws,
      heightMeters: heightMeters ?? this.heightMeters,
      style: style ?? this.style,
      description: description ?? this.description,
      setter: setter ?? this.setter,
      firstAscent: firstAscent ?? this.firstAscent,
      isMultiPitch: isMultiPitch ?? this.isMultiPitch,
      pitches: pitches ?? this.pitches,
    );
  }
}
