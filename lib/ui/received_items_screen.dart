import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:shipment_mate/domain/permanent_state_provider.dart';
import 'package:shipment_mate/ui/item_data_widget.dart';
import 'package:collection/collection.dart';

class ReceivedItemsScreen extends ConsumerWidget {
  const ReceivedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedItemsAsync = ref.watch(permanentStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items'),
      ),
      body: receivedItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No received items yet.'));
          }

          final groupedResults = groupBy(
            items,
            (ItemData item) => item.requisitionNo,
          );
          final sortedPrNumbers = groupedResults.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedPrNumbers.length,
            itemBuilder: (context, index) {
              final prNumber = sortedPrNumbers[index];
              final itemsInGroup = groupedResults[prNumber]!;

              return ExpansionTile(
                title: Text(
                  'PR: $prNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${itemsInGroup.length} items'),
                initiallyExpanded: true,
                children: itemsInGroup.map((item) {
                  return ItemDataWidget(item: item);
                }).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
