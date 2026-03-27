import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(p.join(appDirectory.path, 'vocab.sqlite'));
    return NativeDatabase.createInBackground(databaseFile);
  });
}
