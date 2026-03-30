import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_app/src/app/app.dart';
import 'package:vocab_app/src/core/audio/pronunciation_service.dart';
import 'package:vocab_app/src/core/database/app_database.dart';

void main() {
  testWidgets('홈 대시보드가 로드된다', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      DeutschFlowApp(
        database: database,
        pronunciationService: SilentPronunciationService(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Deutsch Flow'), findsOneWidget);
    expect(find.textContaining('Guten Tag'), findsOneWidget);
    expect(find.text('단어 추가'), findsOneWidget);
  });
}
