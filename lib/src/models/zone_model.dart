class Zone {
  final String id;
  final String name;
  final ZoneType type;
  final String svgUrl;

  const Zone({required this.id, required this.name, required this.type, required this.svgUrl});
}

enum ZoneType { bouldering, ropedClimbing }
