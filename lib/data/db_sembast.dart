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
      store.add(db, updatedEntry.toMap());
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
        yield ItemData.fromMap(entry.value);
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
