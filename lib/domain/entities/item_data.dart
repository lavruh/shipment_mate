import 'package:shipment_mate/domain/entities/data_field.dart';
import 'package:collection/collection.dart';

class ItemData {
  static final List<DataField> fields = [
    DataField(title: 'SMMS no', type: AllowedType.string, columnLetterInExcel: 'AF'),
    DataField(title: 'Item name', type: AllowedType.string, columnLetterInExcel: 'AG'),
    DataField(title: 'Req Qty', type: AllowedType.integer, columnLetterInExcel: 'AJ'),
    DataField(title: 'PR Line status', type: AllowedType.boolean, columnLetterInExcel: 'AN'),
    DataField(title: 'PR', type: AllowedType.string, columnLetterInExcel: 'C'),
    DataField(title: 'PR Description', type: AllowedType.string, columnLetterInExcel: 'I'),
    DataField(title: 'PR Line no', type: AllowedType.integer, columnLetterInExcel: 'AE'),
    DataField(title: 'Requested By', type: AllowedType.string, columnLetterInExcel: 'AS'),
    DataField(title: 'Department', type: AllowedType.string, columnLetterInExcel: 'M'),
    DataField(title: 'Delivery Type', type: AllowedType.string, columnLetterInExcel: 'N'),
    DataField(title: 'Acknowledged Date', type: AllowedType.date, columnLetterInExcel: 'G'),
    DataField(title: 'Acknowledged By', type: AllowedType.string, columnLetterInExcel: 'H'),
    DataField(title: 'WO', type: AllowedType.string, columnLetterInExcel: 'P'),
    DataField(title: 'WO Title', type: AllowedType.string, columnLetterInExcel: 'Q'),
    DataField(title: 'PO', type: AllowedType.string, columnLetterInExcel: 'AT'),
    DataField(title: 'GRA', type: AllowedType.string, columnLetterInExcel: 'AX'),
    DataField(title: 'ERPPR', type: AllowedType.integer, columnLetterInExcel: 'BG'),
    DataField(title: 'Transport no', type: AllowedType.string, columnLetterInExcel: 'BP'),
    DataField(title: 'Handling Unit', type: AllowedType.string, columnLetterInExcel: 'BQ'),
    DataField(title: 'Received Qty', type: AllowedType.integer, columnLetterInExcel: ''),
  ];

  final Map<String, dynamic> values;
  final Map<String, String> extraFields;

  ItemData({
    required this.values,
    required this.extraFields,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>.from(values);
    // Convert DateTime to ISO string for storage
    fields.forEach((field) {
      if (field.type == AllowedType.date && map[field.title] is DateTime) {
        map[field.title] = (map[field.title] as DateTime).toIso8601String();
      }
    });
    map['extraFields'] = extraFields;
    return map;
  }

  factory ItemData.fromMap(Map<String, dynamic> map) {
    final values = <String, dynamic>{};
    fields.forEach((field) {
      var val = map[field.title];
      if (field.type == AllowedType.date && val is String) {
        val = DateTime.tryParse(val);
      }
      values[field.title] = val;
    });
    return ItemData(
      values: values,
      extraFields: Map<String, String>.from(map['extraFields'] ?? {}),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    fields.forEach((field) {
      buffer.writeln('${field.title}: ${field.type.toDisplayString(values[field.title])}');
    });
    buffer.write('extraFields: $extraFields');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemData &&
          runtimeType == other.runtimeType &&
          const MapEquality().equals(values, other.values) &&
          const MapEquality().equals(extraFields, other.extraFields);

  @override
  int get hashCode =>
      const MapEquality().hash(values) ^ const MapEquality().hash(extraFields);

  ItemData copyWith({
    Map<String, dynamic>? values,
    Map<String, String>? extraFields,
  }) {
    return ItemData(
      values: values ?? Map<String, dynamic>.from(this.values),
      extraFields: extraFields ?? Map<String, String>.from(this.extraFields),
    );
  }

  ItemData copyWithUpdate(String key, dynamic value) {
    final newValues = Map<String, dynamic>.from(values);
    newValues[key] = value;
    return copyWith(values: newValues);
  }

  // Getters for convenience (optional, but helps keep existing code working)
  String get itemSMMSNumber => values['SMMS no'] ?? '';
  String get itemName => values['Item name'] ?? '';
  int get reqQty => values['Req Qty'] ?? 0;
  bool get prLineStatus => values['PR Line status'] ?? false;
  String get requisitionNo => values['PR'] ?? '';
  String get prDescription => values['PR Description'] ?? '';
  int get prLineNumber => values['PR Line no'] ?? 0;
  String get requestedBy => values['Requested By'] ?? '';
  String get department => values['Department'] ?? '';
  String get deliveryType => values['Delivery Type'] ?? '';
  DateTime get acknowledgedDate => values['Acknowledged Date'] ?? DateTime.now();
  String get acknowledgedBy => values['Acknowledged By'] ?? '';
  String? get woNumber => values['WO'];
  String? get woTitle => values['WO Title'];
  String? get poNumber => values['PO'];
  String? get graNumber => values['GRA'];
  int? get erpPrNumber => values['ERPPR'];
  int? get transportNumber => values['Transport no'];
  int? get handlingUnit => values['Handling Unit'];
  int get receivedQty => values['Received Qty'] ?? 0;
}
