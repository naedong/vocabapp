import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_app/src/app/responsive_layout.dart';
import 'package:vocab_app/src/core/database/app_database.dart';

void main() {
  test('추천 단어를 저장하면 문법 메모와 날짜 키가 함께 저장된다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.addWord(
      german: 'Rechnung',
      article: 'die',
      meaningEn: 'bill',
      meaningKo: '계산서',
      pronunciation: '/ˈʁɛçnʊŋ/',
      ttsLocale: 'de-DE',
      partOfSpeech: 'noun',
      exampleSentence: 'Kann ich bitte die Rechnung bekommen?',
      exampleTranslation: '계산서 좀 받을 수 있을까요?',
      deck: '오늘의 추천',
      grammarNote: '명사는 die와 함께 외우면 여성 명사라는 점을 같이 기억하기 좋습니다.',
      isDailyRecommendation: true,
      dailyRecommendationDate: DateTime(2026, 4, 10),
    );

    final words = await database.select(database.vocabWords).get();
    expect(words, hasLength(1));
    expect(words.single.german, 'Rechnung');
    expect(words.single.grammarNote, contains('여성 명사'));
    expect(words.single.isDailyRecommendation, isTrue);
    expect(words.single.dailyRecommendationDateKey, '2026-04-10');
  });

  group('ResponsiveLayout', () {
    test('compact width uses phone-sized spacing', () {
      final layout = ResponsiveLayout.fromWidth(390);

      expect(layout.isCompact, isTrue);
      expect(layout.pagePadding, 16);
      expect(layout.cardPadding, 18);
      expect(layout.columnsFor(minTileWidth: 210), 1);
    });

    test('tablet width keeps readable max width and multi-column cards', () {
      final layout = ResponsiveLayout.fromWidth(820);

      expect(layout.isTablet, isTrue);
      expect(layout.isExpanded, isFalse);
      expect(layout.pagePadding, 24);
      expect(layout.maxReadableWidth, 920);
      expect(layout.columnsFor(minTileWidth: 210), 3);
    });

    test('expanded width enables desktop density', () {
      final layout = ResponsiveLayout.fromWidth(1280);

      expect(layout.isExpanded, isTrue);
      expect(layout.panelRadius, 34);
      expect(layout.displayTitleSize, 34);
      expect(layout.columnsFor(minTileWidth: 210), 4);
    });
  });
}
