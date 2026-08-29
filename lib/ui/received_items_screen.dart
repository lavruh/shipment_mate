import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:shipment_mate/domain/permanent_state_provider.dart';
import 'package:shipment_mate/ui/item_data_widget.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ReceivedItemsScreen extends ConsumerWidget {
  const ReceivedItemsScreen({super.key});

  Future<void> _exportToExcel(
    BuildContext context,
    List<ItemData> items,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Headers
    final headers = ItemData.fields.map((f) => f.title).toList();
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data
    for (final item in items) {
      final row = ItemData.fields.map((field) {
        final val = item.values[field.title];
        return TextCellValue(field.type.toDisplayString(val));
      }).toList();
      sheet.appendRow(row);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final fileName =
        "received_items_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final uint8List = Uint8List.fromList(bytes);

    final outputFile = await FilePicker.saveFile(
      fileName: fileName,
      bytes: uint8List,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File saved to $outputFile')));
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Received Items'),
        content: const Text(
          'Are you sure you want to delete all received items? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(permanentStateProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('List cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedItemsAsync = ref.watch(permanentStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items'),
        actions: [
          receivedItemsAsync.maybeWhen(
            data: (items) => items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export to Excel',
                    onPressed: () => _exportToExcel(context, items),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
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
