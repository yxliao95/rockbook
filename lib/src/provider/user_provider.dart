import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

class UserSessionState {
  final List<AppUser> users;
  final String? currentUserId;

  const UserSessionState({required this.users, this.currentUserId});

  AppUser? get currentUser {
    if (currentUserId == null) return null;
    return users.firstWhere((user) => user.id == currentUserId, orElse: () => users.first);
  }

  UserSessionState copyWith({List<AppUser>? users, String? currentUserId}) {
    return UserSessionState(users: users ?? this.users, currentUserId: currentUserId ?? this.currentUserId);
  }
}

class UserSessionNotifier extends Notifier<UserSessionState> {
  @override
  UserSessionState build() {
    return UserSessionState(users: _seedUsers());
  }

  bool login({required String nickname, required String password}) {
    final match = state.users.where((user) => user.nickname == nickname && user.password == password);
    if (match.isEmpty) return false;
    state = state.copyWith(currentUserId: match.first.id);
    return true;
  }

  bool register({required String nickname, required String password}) {
    if (state.users.any((user) => user.nickname == nickname)) {
      return false;
    }
    final id = 'u${DateTime.now().millisecondsSinceEpoch}';
    final user = AppUser(id: id, nickname: nickname, password: password);
    state = state.copyWith(users: [...state.users, user], currentUserId: id);
    return true;
  }

  void logout() {
    state = state.copyWith(currentUserId: null);
  }

  void updateProfile(AppUser updated) {
    final next = state.users.map((user) => user.id == updated.id ? updated : user).toList();
    state = state.copyWith(users: next);
  }

  List<AppUser> _seedUsers() {
    return const [
      AppUser(id: 'u1', nickname: '阿岩', password: '123456', heightCm: 178, armSpanCm: 182, weightKg: 68),
      AppUser(id: 'u2', nickname: '木木', password: '123456', heightCm: 165, armSpanCm: 170, weightKg: 54),
      AppUser(id: 'u3', nickname: '石头', password: '123456', heightCm: 182, armSpanCm: 186, weightKg: 76),
    ];
  }
}

final userSessionProvider = NotifierProvider<UserSessionNotifier, UserSessionState>(UserSessionNotifier.new);

final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(userSessionProvider);
  final userId = state.currentUserId;
  if (userId == null) return null;
  return state.users.firstWhere((user) => user.id == userId);
});

final isLoggedInProvider = Provider<bool>((ref) => ref.watch(currentUserProvider) != null);

final allUsersProvider = Provider<List<AppUser>>((ref) => ref.watch(userSessionProvider).users);

final userByIdProvider = Provider.family<AppUser?, String>((ref, userId) {
  return ref.watch(allUsersProvider).where((user) => user.id == userId).firstOrNull;
});

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
