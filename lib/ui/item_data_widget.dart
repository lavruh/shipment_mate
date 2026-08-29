import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:shipment_mate/domain/permanent_state_provider.dart';
import 'package:shipment_mate/ui/item_details_screen.dart';
import 'package:shipment_mate/ui/received_input_widget.dart';
import 'package:collection/collection.dart';

class ItemDataWidget extends ConsumerWidget {
  final ItemData item;

  const ItemDataWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedItemsAsync = ref.watch(permanentStateProvider);
    
    final savedItem = receivedItemsAsync.maybeWhen(
      data: (items) => items.firstWhereOrNull((i) =>
          i.itemSMMSNumber == item.itemSMMSNumber &&
          i.requisitionNo == item.requisitionNo &&
          i.itemName == item.itemName &&
          i.prLineNumber == item.prLineNumber),
      orElse: () => null,
    );

    final isReceived = savedItem != null;
    final currentReceivedQty = savedItem?.receivedQty ?? item.receivedQty;

    return Slidable(
      key: ValueKey(item.hashCode),
      endActionPane: ActionPane(
        extentRatio: isReceived ? 0.4 : 0.25,
        motion: const ScrollMotion(),
        children: [
          if (isReceived)
            SlidableAction(
              onPressed: (_) async {
                await ref.read(permanentStateProvider.notifier).removeItem(savedItem);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item removed from received list')),
                  );
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          CustomSlidableAction(
            padding: EdgeInsets.zero,
            onPressed: (_) {},
            autoClose: false,
            backgroundColor: Colors.green,
            child: ReceivedInput(
              initialValue: currentReceivedQty > 0 ? currentReceivedQty : item.reqQty,
              onConfirm: (val) async {
                final receivedItem = item.copyWithUpdate('Received Qty', val);
                await ref.read(permanentStateProvider.notifier).saveItem(receivedItem);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item saved to received items')),
                  );
                  Slidable.of(context)?.close();
                }
              },
            ),
          ),
        ],
      ),
      child: Card(
        color: isReceived ? Colors.lightGreen.shade100 : null,
        margin: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 4,
        ),
        child: ListTile(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                ),
                child: Text(
                  item.itemSMMSNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  item.itemName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Text(
            currentReceivedQty > 0
                ? '$currentReceivedQty / ${item.reqQty}'
                : item.reqQty.toString(),
            style: TextStyle(
              color: currentReceivedQty > 0 ? Colors.green.shade700 : null,
              fontWeight: currentReceivedQty > 0 ? FontWeight.bold : null,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(item: savedItem ?? item),
              ),
            );
          },
        ),
      ),
    );
  }
}
