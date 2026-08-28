import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/db_provider.dart';
import 'package:shipment_mate/ui/search_screen.dart';
import 'package:shipment_mate/ui/source_select_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbPath = ref.watch(dbPathProvider);

    return MaterialApp(
      title: 'Shipment Mate',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: dbPath == null ? const SourceSelectScreen() : const SearchScreen(),
    );
  }
}
