import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'repository_providers.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});