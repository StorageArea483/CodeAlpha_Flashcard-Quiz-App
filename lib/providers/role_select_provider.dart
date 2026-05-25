import 'package:flutter_riverpod/legacy.dart';

final isLoading = StateProvider.autoDispose<bool>((ref) => false);

final isNotEmpty = StateProvider.autoDispose<bool>((ref) => false);

final testNames = StateProvider.autoDispose<List<String>>((ref) => []);
