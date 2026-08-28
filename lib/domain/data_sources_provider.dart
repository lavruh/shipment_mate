import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final dataSourcesProvider = FutureProvider<List<File>>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync();
  
  return files
      .whereType<File>()
      .where((file) => file.path.endsWith('.db'))
      .toList();
});
