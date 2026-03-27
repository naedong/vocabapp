import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'vocab_web_db',
      sqlite3Uri: Uri.parse('packages/sqlite3/assets/wasm/sqlite3.wasm'),
      driftWorkerUri: Uri.parse('packages/drift/wasm/drift_worker.js'),
    );

    return result.resolvedExecutor.executor;
  });
}
