import 'dart:io';

import 'package:excel/excel.dart';
import 'package:shipment_mate/data/i_data_base.dart';
import 'package:shipment_mate/data/i_data_file_converter.dart';
import 'package:shipment_mate/domain/entities/data_field.dart';
import 'package:shipment_mate/domain/entities/item_data.dart';

class DataFileConverterXlsx implements IDataFileConverter {
   @override
  Future<void> convert({
    required File source,
    required IDataBase db,
    Function({String? message, int? precent})? onProgress,
    Function()? onComplete,
    Function({required String message})? onError,
  }) async {
    try {
      onProgress?.call(message: 'Reading file...');
      final bytes = await source.readAsBytes();
      onProgress?.call(message: 'Converting file...');
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel['DATA_Set'];
      if (sheet == null) {
        onError?.call(message: 'Sheet "DATA_Set" not found');
        return;
      }

      final rows = sheet.rows;
      if (rows.isEmpty) {
        onError?.call(message: 'Sheet is empty');
        return;
      }

      final totalRows = rows.length;
      
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        final rowData = <String, dynamic>{};

        ItemData.fields.forEach((field) {
          final columnLetter = field.columnLetterInExcel;
          if (columnLetter.isEmpty) return;
          final colIndex = _columnLetterToIndex(columnLetter);
          if (colIndex >= 0 && colIndex < row.length) {
            rowData[field.title] = row[colIndex]?.value;
          }
        });

        final itemData = _mapRowToItemData(rowData);
        if (itemData.itemSMMSNumber.isNotEmpty) {
          await db.insertEntry(table: 'items', updatedEntry: itemData);
        }

        final progress = ((i + 1) / totalRows * 100).toInt();
        onProgress?.call(precent: progress, message: 'Processing row ${i + 1} of $totalRows');
      }

      onComplete?.call();
    } catch (e) {
      onError?.call(message: 'Error converting file: $e');
    }
  }

  int _columnLetterToIndex(String columnLetter) {
    int index = 0;
    for (int i = 0; i < columnLetter.length; i++) {
      index = index * 26 + (columnLetter.codeUnitAt(i) - 64);
    }
    return index - 1;
  }

  ItemData _mapRowToItemData(Map<String, dynamic> rowData) {
    final values = <String, dynamic>{};
    ItemData.fields.forEach((field) {
      final val = rowData[field.title];
      values[field.title] = field.type.fromDataSource(val);
    });

    return ItemData(
      values: values,
      extraFields: _extractExtraFields(rowData),
    );
  }

  Map<String, String> _extractExtraFields(Map<String, dynamic> data) {
    final extraFields = <String, String>{};
    final fieldTitles = ItemData.fields.map((f) => f.title).toSet();
    for (final key in data.keys) {
      if (!fieldTitles.contains(key)) {
        final value = data[key];
        if (value != null) {
          extraFields[key] = value.toString();
        }
      }
    }
    return extraFields;
  }
}
