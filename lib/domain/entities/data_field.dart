enum AllowedType {
  string,
  date,
  integer,
  boolean;

  dynamic fromDataSource(dynamic value) {
    switch (this) {
      case AllowedType.string:
        return value?.toString() ?? '';
      case AllowedType.integer:
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        return int.tryParse(value.toString()) ?? 0;
      case AllowedType.boolean:
        if (value is bool) return value;
        if (value is String) return value.toLowerCase() == 'true';
        return false;
      case AllowedType.date:
        if (value is DateTime) return value;
        if (value == null) return DateTime.now();

        final dateStr = value.toString().trim();
        if (dateStr.isEmpty) return DateTime.now();

        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) return parsed;

        final parts = dateStr.split(RegExp(r'[-./]'));
        if (parts.length == 3) {
          final p0 = int.tryParse(parts[0]);
          final p1 = int.tryParse(parts[1]);
          final p2 = int.tryParse(parts[2]);

          if (p0 != null && p1 != null && p2 != null) {
            if (p2 > 1000) {
              return DateTime(p2, p1, p0);
            } else if (p0 > 1000) {
              return DateTime(p0, p1, p2);
            }
          }
        }
        return DateTime.now();
    }
  }

  String toDisplayString(dynamic value) {
    if (value == null) return '';
    if (this == AllowedType.date && value is DateTime) {
      return "${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}";
    }
    return value.toString();
  }
}

class DataField {
  final String title;
  final AllowedType type;
  final String columnLetterInExcel;

  DataField({
    required this.title,
    required this.type,
    required this.columnLetterInExcel,
  });
}
