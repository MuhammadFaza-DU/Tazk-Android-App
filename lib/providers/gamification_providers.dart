import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'repository_providers.dart';

final userProfileProvider = StreamProvider<UserProfileData>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  repo.ensureProfile();
  return repo.watchProfile();
});

final streakStateProvider = StreamProvider<StreakStateData>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  repo.ensureStreakState();
  return repo.watchStreakState();
});

final badgesProvider = StreamProvider<List<BadgeUnlock>>((ref) {
  return ref.watch(gamificationRepositoryProvider).watchBadges();
});

final cosmeticsProvider = StreamProvider<List<CosmeticUnlock>>((ref) {
  return ref.watch(gamificationRepositoryProvider).watchCosmetics();
});
