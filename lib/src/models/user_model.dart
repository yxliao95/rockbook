class AppUser {
  final String id;
  final String nickname;
  final String password;
  final int? heightCm;
  final int? armSpanCm;
  final int? weightKg;

  const AppUser({
    required this.id,
    required this.nickname,
    required this.password,
    this.heightCm,
    this.armSpanCm,
    this.weightKg,
  });

  AppUser copyWith({
    String? id,
    String? nickname,
    String? password,
    int? heightCm,
    int? armSpanCm,
    int? weightKg,
  }) {
    return AppUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      heightCm: heightCm ?? this.heightCm,
      armSpanCm: armSpanCm ?? this.armSpanCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
