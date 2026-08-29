import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/domain/db_provider.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';
import 'package:collection/collection.dart';

class PermanentStateNotifier extends AsyncNotifier<List<ItemData>> {
  static const String _tableName = 'received_items';

  @override
  Future<List<ItemData>> build() async {
    final db = await ref.watch(todosDbProvider.future);
    final stream = db.getEntries(table: _tableName);
    return await stream.toList();
  }

  Future<void> saveItem(ItemData item) async {
    final db = await ref.read(todosDbProvider.future);
    
    // Check if an item with the same identity already exists
    final existing = state.value?.firstWhereOrNull((i) =>
        i.itemSMMSNumber == item.itemSMMSNumber &&
        i.requisitionNo == item.requisitionNo &&
        i.itemName == item.itemName &&
        i.prLineNumber == item.prLineNumber);

    if (existing != null) {
      await db.deleteEntry(table: _tableName, entry: existing);
    }
    
    await db.insertEntry(table: _tableName, updatedEntry: item);
    ref.invalidateSelf();
    await future;
  }

  Future<void> saveItems(List<ItemData> items) async {
    final db = await ref.read(todosDbProvider.future);
    await db.insertEntries(table: _tableName, entries: items);

    ref.invalidateSelf();
    await future;
  }

  Future<void> removeItem(ItemData item) async {
    final db = await ref.read(todosDbProvider.future);
    await db.deleteEntry(table: _tableName, entry: item);

    ref.invalidateSelf();
    await future;
  }
}

final permanentStateProvider =
    AsyncNotifierProvider<PermanentStateNotifier, List<ItemData>>(
        PermanentStateNotifier.new);
