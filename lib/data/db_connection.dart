import 'package:drift/drift.dart';

import 'db_connection_web.dart'
    if (dart.library.io) 'db_connection_native.dart'
    as impl;

QueryExecutor openConnection() => impl.openConnection();
