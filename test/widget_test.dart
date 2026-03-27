import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_app/main.dart';

void main() {
  testWidgets('Drift 초기 구성 타이틀 노출', (WidgetTester tester) async {
    await tester.pumpWidget(const VocabApp());

    expect(find.text('독일어 앱 초기 구성 (Drift 연결 완료)'), findsOneWidget);
  });
}
