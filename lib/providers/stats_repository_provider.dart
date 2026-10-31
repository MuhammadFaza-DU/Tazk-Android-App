import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/stats_repository.dart';
import 'database_provider.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(appDatabaseProvider));
});