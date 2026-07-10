import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'repository_providers.dart';

final appSettingsProvider = StreamProvider<AppSetting>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  repo.ensureSettings();
  return repo.watchSettings();
});
