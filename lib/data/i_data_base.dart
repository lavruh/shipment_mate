import 'package:shipment_mate/domain/entities/item_data.dart';

abstract class IDataBase {
  Future<bool> openDbFromFile({required String path});
  Stream<ItemData> getEntries({required String table, ItemData? filters});
  Future<void> insertEntry({required String  table, required ItemData updatedEntry});
  Future<void> insertEntries({required String table, required List<ItemData> entries});
  Future<void> deleteEntry({required String table, required ItemData entry});
  Future<void> clearTable({required String table});
}
