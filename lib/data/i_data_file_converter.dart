import 'dart:io';

import 'package:shipment_mate/data/i_data_base.dart';

abstract class IDataFileConverter {
  Future<void> convert({
    required File source,
    required IDataBase db,
    Function({int? precent, String? message})? onProgress,
    Function()? onComplete,
    Function({required String message})? onError,
  });
}
