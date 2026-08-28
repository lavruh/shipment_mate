import 'dart:io';
import 'dart:isolate';

import 'package:excel/excel.dart';
import 'package:shipment_mate/data/i_data_base.dart';
import 'package:shipment_mate/data/i_data_file_converter.dart';
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
      onProgress?.call(message: 'Reading file...', precent: 5);
      final bytes = await source.readAsBytes();

      onProgress?.call(message: 'Parsing Excel in background...', precent: 15);

      // Perform heavy Excel parsing in a separate isolate to avoid UI jank
      final parseResult = await Isolate.run(() => _parseExcelIsolate(bytes));

      if (parseResult.error != null) {
        onError?.call(message: parseResult.error!);
        return;
      }

      final rawDataList = parseResult.data!;
      final totalRows = rawDataList.length;

      onProgress?.call(message: 'Checking existing entries...', precent: 40);
      final existingEntries = <ItemData>{};
      await for (final entry in db.getEntries(table: 'items')) {
        existingEntries.add(entry);
      }

      final toInsert = <ItemData>[];
      for (int i = 0; i < rawDataList.length; i++) {
        final rowData = rawDataList[i];
        final itemData = _mapRowToItemData(rowData);

        if (itemData.itemSMMSNumber.isNotEmpty &&
            !existingEntries.contains(itemData)) {
          toInsert.add(itemData);
          existingEntries.add(itemData);
        }

        if (i % 100 == 0) {
          final progress = 40 + ((i / totalRows) * 40).toInt();
          onProgress?.call(
            precent: progress,
            message: 'Processing row ${i + 1} of $totalRows',
          );
          // Yield to UI thread
          await Future.delayed(Duration.zero);
        }
      }

      if (toInsert.isNotEmpty) {
        onProgress?.call(
          message: 'Saving ${toInsert.length} new entries...',
          precent: 90,
        );
        await db.insertEntries(table: 'items', entries: toInsert);
      }

      onProgress?.call(message: 'Complete!', precent: 100);
      onComplete?.call();
    } catch (e) {
      onError?.call(message: 'Error converting file: $e');
    }
  }

  // Top-level or static method for Isolate.run
  static _ParseResult _parseExcelIsolate(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel['DATA_Set'];
      if (sheet == null) return _ParseResult(error: 'Sheet "DATA_Set" not found');

      final rows = sheet.rows;
      if (rows.isEmpty) return _ParseResult(error: 'Sheet is empty');

      final resultData = <Map<String, dynamic>>[];

      for (final row in rows) {
        final rowData = <String, dynamic>{};
        bool hasData = false;

        for (final field in ItemData.fields) {
          final columnLetter = field.columnLetterInExcel;
          if (columnLetter.isEmpty) continue;

          final colIndex = _columnLetterToIndexStatic(columnLetter);
          if (colIndex >= 0 && colIndex < row.length) {
            final value = row[colIndex]?.value;
            rowData[field.title] = value;
            if (value != null) hasData = true;
          }
        }

        if (hasData) {
          resultData.add(rowData);
        }
      }

      return _ParseResult(data: resultData);
    } catch (e) {
      return _ParseResult(error: 'Isolate error: $e');
    }
  }

  static int _columnLetterToIndexStatic(String columnLetter) {
    int index = 0;
    for (int i = 0; i < columnLetter.length; i++) {
      index = index * 26 + (columnLetter.codeUnitAt(i) - 64);
    }
    return index - 1;
  }

  ItemData _mapRowToItemData(Map<String, dynamic> rowData) {
    final values = <String, dynamic>{};
    for (final field in ItemData.fields) {
      final val = rowData[field.title];
      values[field.title] = field.type.fromDataSource(val);
    }

    return ItemData(
      values: values,
      extraFields: {}, // Extra fields are harder to track in dynamic schema without specific logic
    );
  }
}

class _ParseResult {
  final List<Map<String, dynamic>>? data;
  final String? error;
  _ParseResult({this.data, this.error});
}
