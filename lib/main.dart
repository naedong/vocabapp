import 'package:flutter/widgets.dart';

import 'src/core/localization/app_locale.dart';
import 'src/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalization.ensureInitialized();
  runApp(const DeutschFlowApp());
}
