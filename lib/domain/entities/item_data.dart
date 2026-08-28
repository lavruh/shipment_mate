import 'package:shipment_mate/domain/entities/data_field.dart';

class ItemData {
  static final List<DataField> fields = [
    DataField(title: 'itemSMMSNumber', type: AllowedType.string, columnLetterInExcel: 'AF'),
    DataField(title: 'itemName', type: AllowedType.string, columnLetterInExcel: 'AG'),
    DataField(title: 'reqQty', type: AllowedType.integer, columnLetterInExcel: 'AJ'),
    DataField(title: 'prLineStatus', type: AllowedType.boolean, columnLetterInExcel: 'AN'),
    DataField(title: 'PR no', type: AllowedType.string, columnLetterInExcel: 'C'),
    DataField(title: 'prDescription', type: AllowedType.string, columnLetterInExcel: 'I'),
    DataField(title: 'prLineNumber', type: AllowedType.integer, columnLetterInExcel: 'AE'),
    DataField(title: 'requestedBy', type: AllowedType.string, columnLetterInExcel: 'AS'),
    DataField(title: 'department', type: AllowedType.string, columnLetterInExcel: 'M'),
    DataField(title: 'deliveryType', type: AllowedType.string, columnLetterInExcel: 'N'),
    DataField(title: 'acknowledgedDate', type: AllowedType.date, columnLetterInExcel: 'G'),
    DataField(title: 'acknowledgedBy', type: AllowedType.string, columnLetterInExcel: 'H'),
    DataField(title: 'woNumber', type: AllowedType.string, columnLetterInExcel: 'P'),
    DataField(title: 'woTitle', type: AllowedType.string, columnLetterInExcel: 'Q'),
    DataField(title: 'poNumber', type: AllowedType.string, columnLetterInExcel: 'AT'),
    DataField(title: 'graNumber', type: AllowedType.string, columnLetterInExcel: 'AX'),
    DataField(title: 'erpPrNumber', type: AllowedType.integer, columnLetterInExcel: 'BG'),
    DataField(title: 'transportNumber', type: AllowedType.string, columnLetterInExcel: 'BP'),
    DataField(title: 'Handling Unit', type: AllowedType.string, columnLetterInExcel: 'BQ'),
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

  // Getters for convenience (optional, but helps keep existing code working)
  String get itemSMMSNumber => values['itemSMMSNumber'] ?? '';
  String get itemName => values['itemName'] ?? '';
  int get reqQty => values['reqQty'] ?? 0;
  bool get prLineStatus => values['prLineStatus'] ?? false;
  String get requisitionNo => values['PR no'] ?? '';
  String get prDescription => values['prDescription'] ?? '';
  int get prLineNumber => values['prLineNumber'] ?? 0;
  String get requestedBy => values['requestedBy'] ?? '';
  String get department => values['department'] ?? '';
  String get deliveryType => values['deliveryType'] ?? '';
  DateTime get acknowledgedDate => values['acknowledgedDate'] ?? DateTime.now();
  String get acknowledgedBy => values['acknowledgedBy'] ?? '';
  String? get woNumber => values['woNumber'];
  String? get woTitle => values['woTitle'];
  String? get poNumber => values['poNumber'];
  String? get graNumber => values['graNumber'];
  int? get erpPrNumber => values['erpPrNumber'];
  int? get transportNumber => values['transportNumber'];
  int? get handlingUnit => values['Handling Unit'];
}
