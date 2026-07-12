import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home_widget_service.dart';
import 'database_provider.dart';
import 'repository_providers.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsRepositoryProvider),
  );
});
