import 'dart:io';

import 'package:sembast/sembast_io.dart';
import 'package:shipment_mate/data/i_data_base.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';

class DbSembast implements IDataBase {
  Database? _database;
  // late final StoreRef<int, Map<String, dynamic>> _store;


  @override
  Future<void> insertEntry({
    required String table,
    required ItemData updatedEntry,
  }) async {
    final db = _database;
    if (db != null) {
      final store = intMapStoreFactory.store(table);
      await store.add(db, updatedEntry.toMap());
    }
  }

  @override
  Future<void> insertEntries({
    required String table,
    required List<ItemData> entries,
  }) async {
    final db = _database;
    if (db != null) {
      final store = intMapStoreFactory.store(table);
      await db.transaction((txn) async {
        for (final entry in entries) {
          await store.add(txn, entry.toMap());
        }
      });
    }
  }

  @override
  Future<void> deleteEntry({
    required String table,
    required ItemData entry,
  }) async {
    final db = _database;
    if (db != null) {
      final store = intMapStoreFactory.store(table);
      // We search for the exact match of the map representation
      await store.delete(
        db,
        finder: Finder(filter: Filter.custom((record) {
          final recordItem = ItemData.fromMap(record.value as Map<String, dynamic>);
          return recordItem == entry;
        })),
      );
    }
  }

  @override
  Future<void> clearTable({required String table}) async {
    final db = _database;
    if (db != null) {
      final store = intMapStoreFactory.store(table);
      await store.delete(db);
    }
  }

  @override
  Stream<ItemData> getEntries({
    required String table,
    ItemData? filters,
  }) async* {
    final db = _database;
    if (db != null) {
      final store = intMapStoreFactory.store(table);
      final entries = await store.find(
        db,
        finder: Finder(filter: _filterFromItemData(filters)),
      );
      for (final entry in entries) {
        yield ItemData.fromMap(entry.value as Map<String, dynamic>);
      }
    }
  }

  @override
  Future<bool> openDbFromFile({required String path}) async {
    if (!File(path).existsSync()) {
      File(path).createSync();
    }
    _database ??= await databaseFactoryIo.openDatabase(path);
    return true;
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Filter? _filterFromItemData(ItemData? filters) {
    if (filters == null) return null;
    final fields = filters.values;
    if (fields.isEmpty) return null;
    List<Filter> filtersList = [];
    for (final field in fields.entries) {
      final value = field.value;
      if (value != null) {
        if (value is String && value.isEmpty) continue;
        if (value is int && value == 0) continue;
        if (value is bool && value == false) continue;

        if (value is DateTime) {
          filtersList.add(Filter.equals(field.key, value.toIso8601String()));
        } else if (value is String) {
          filtersList.add(Filter.matches(field.key, value));
        } else {
          filtersList.add(Filter.equals(field.key, value));
        }
      }
    }
    return filtersList.isEmpty ? null : Filter.and(filtersList);
  }
}
