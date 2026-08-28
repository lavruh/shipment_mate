import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipment_mate/data/db_sembast.dart';
import 'package:shipment_mate/data/i_data_base.dart';

class DbPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  set state(String? value) => super.state = value;
}

final dbPathProvider = NotifierProvider<DbPathNotifier, String?>(DbPathNotifier.new);

final todosDbProvider = FutureProvider<IDataBase>((ref) async {
  final path = ref.watch(dbPathProvider);
  if (path == null) {
    throw Exception('DB path is not set');
  }
  final db = DbSembast();
  await db.openDbFromFile(path: path);
  return db;
});
