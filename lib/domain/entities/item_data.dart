import 'package:shipment_mate/domain/entities/data_field.dart';

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
    for (final field in fields) {
      final val = map[field.title];
      // Use the field's type to correctly parse the value from the data source
      values[field.title] = field.type.fromDataSource(val);
    }
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
          itemSMMSNumber == other.itemSMMSNumber &&
          reqQty == other.reqQty &&
          requisitionNo == other.requisitionNo &&
          requestedBy == other.requestedBy &&
          handlingUnit == other.handlingUnit;

  @override
  int get hashCode =>
      itemSMMSNumber.hashCode ^
      reqQty.hashCode ^
      requisitionNo.hashCode ^
      requestedBy.hashCode ^
      handlingUnit.hashCode;

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
  String get itemSMMSNumber => AllowedType.string.fromDataSource(values['SMMS no']);
  String get itemName => AllowedType.string.fromDataSource(values['Item name']);
  int get reqQty => AllowedType.integer.fromDataSource(values['Req Qty']);
  bool get prLineStatus => AllowedType.boolean.fromDataSource(values['PR Line status']);
  String get requisitionNo => AllowedType.string.fromDataSource(values['PR']);
  String get prDescription => AllowedType.string.fromDataSource(values['PR Description']);
  int get prLineNumber => AllowedType.integer.fromDataSource(values['PR Line no']);
  String get requestedBy => AllowedType.string.fromDataSource(values['Requested By']);
  String get department => AllowedType.string.fromDataSource(values['Department']);
  String get deliveryType => AllowedType.string.fromDataSource(values['Delivery Type']);
  DateTime get acknowledgedDate => AllowedType.date.fromDataSource(values['Acknowledged Date']);
  String get acknowledgedBy => AllowedType.string.fromDataSource(values['Acknowledged By']);
  String? get woNumber => values['WO']?.toString();
  String? get woTitle => values['WO Title']?.toString();
  String? get poNumber => values['PO']?.toString();
  String? get graNumber => values['GRA']?.toString();
  int? get erpPrNumber => AllowedType.integer.fromDataSource(values['ERPPR']);
  String? get transportNumber => values['Transport no']?.toString();
  String? get handlingUnit => values['Handling Unit']?.toString();
  int get receivedQty => AllowedType.integer.fromDataSource(values['Received Qty']);
}
