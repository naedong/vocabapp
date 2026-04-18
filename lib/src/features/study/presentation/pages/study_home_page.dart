import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/responsive_layout.dart';
import '../../../../core/audio/pronunciation_assessment_service.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/audio/voice_locale.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_copy.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/settings/app_settings_repository.dart';
import '../../../../core/settings/app_settings_scope.dart';
import '../../../dictionary/application/dictionary_repository.dart';
import '../../../immersion/application/immersion_repository.dart';
import '../../../immersion/application/news_feed_repository.dart';
import '../../../immersion/data/learning_resource_catalog.dart';
import '../pages/exam_practice_page.dart';
import '../pages/daily_recommendations_page.dart';
import '../../../immersion/presentation/pages/immersion_hub_page.dart';
import '../../application/daily_word_recommendation_service.dart';
import '../../application/study_repository.dart';
import '../../application/study_coach_service.dart';
import '../widgets/add_word_sheet.dart';
import '../widgets/app_settings_sheet.dart';
import '../widgets/word_coach_sheet.dart';

String _tr(BuildContext context, String korean, String english) {
  return context.copy(korean: korean, english: english);
}

String _uiPrimaryMeaning(BuildContext context, VocabWord word) {
  return AppSettingsScope.of(
    context,
  ).appLanguage.copy(korean: word.meaningKo, english: word.meaningEn);
}

String _uiSecondaryMeaning(BuildContext context, VocabWord word) {
  return AppSettingsScope.of(
    context,
  ).appLanguage.copy(korean: word.meaningEn, english: word.meaningKo);
}

String _todayPickLabel(BuildContext context) {
  return _tr(context, '오늘 추천', 'Today pick');
}

String _reviewCountLabel(BuildContext context, int timesReviewed) {
  return _tr(context, '리뷰 $timesReviewed회', '$timesReviewed reviews');
}

String _masteryLabel(BuildContext context, int mastery) {
  return _tr(context, '숙련도 $mastery/5', 'Mastery $mastery/5');
}

String _pronunciationLine(BuildContext context, VocabWord word) {
  return _tr(
    context,
    '발음: ${word.pronunciation}  |  음성: ${_wordVoiceLocaleLabel(word)}',
    'Pronunciation: ${word.pronunciation}  |  Voice: ${_wordVoiceLocaleLabel(word)}',
  );
}

String _voiceLocaleLine(BuildContext context, VocabWord word) {
  return _tr(
    context,
    '음성 locale: ${_wordVoiceLocaleLabel(word)}',
    'Voice locale: ${_wordVoiceLocaleLabel(word)}',
  );
}

String _pronunciationMemoLine(BuildContext context, VocabWord word) {
  return _tr(
    context,
    '발음 메모: ${word.pronunciation}\n음성 locale: ${_wordVoiceLocaleLabel(word)}',
    'Pronunciation note: ${word.pronunciation}\nVoice locale: ${_wordVoiceLocaleLabel(word)}',
  );
}

String _wordAudioLabel(BuildContext context) {
  return _tr(context, '단어 듣기', 'Play word');
}

String _exampleAudioLabel(BuildContext context) {
  return _tr(context, '예문 듣기', 'Play example');
}

String _pronunciationCoachLabel(BuildContext context) {
  return _tr(context, '마이크 발음 점검', 'Mic pronunciation check');
}

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({
    super.key,
    required this.repository,
    required this.dictionaryRepository,
    required this.immersionRepository,
    required this.newsFeedRepository,
    required this.pronunciationService,
    required this.pronunciationAssessmentService,
    required this.studyCoachService,
    required this.appSettingsRepository,
    required this.settings,
  });

  final StudyRepository repository;
  final DictionaryRepository dictionaryRepository;
  final ImmersionRepository immersionRepository;
  final NewsFeedRepository newsFeedRepository;
  final PronunciationService pronunciationService;
  final PronunciationAssessmentService pronunciationAssessmentService;
  final StudyCoachService studyCoachService;
  final AppSettingsRepository appSettingsRepository;
  final AppSettingsData settings;

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  String _selectedDeck = 'All';
  bool _revealAnswer = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VocabWord>>(
      stream: widget.repository.watchWords(),
      builder: (context, snapshot) {
        final allWords = List<VocabWord>.from(
          snapshot.data ?? const <VocabWord>[],
        )..sort(_sortWords);
        final words = allWords
            .where(
              (word) => word.languageCode == widget.settings.studyLanguage.code,
            )
            .toList();
        final dueWords = _dueWords(words);
        final todayRecommendedWords = _todayRecommendedWords(words);

        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = ResponsiveLayout.fromConstraints(constraints);
            final shell = _buildShell(
              context,
              words: words,
              dueWords: dueWords,
              todayRecommendedWords: todayRecommendedWords,
              layout: layout,
            );

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    Color(0xFFF0F8F4),
                    Color(0xFFFFF4E8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(children: [const _BackdropOrbs(), shell]),
            );
          },
        );
      },
    );
  }

  Widget _buildShell(
    BuildContext context, {
    required List<VocabWord> words,
    required List<VocabWord> dueWords,
    required List<VocabWord> todayRecommendedWords,
    required ResponsiveLayout layout,
  }) {
    final titles = [
      'Deutsch Flow',
      _tr(context, '단어 컬렉션', 'Word Collection'),
      _tr(context, '복습 세션', 'Review Session'),
      widget.settings.studyLanguage.englishLabel == 'German'
          ? _tr(context, '실전 독일어', 'Real-world German')
          : _tr(context, '실전 허브', 'Immersion Hub'),
      _tr(context, '학습 인사이트', 'Study Insights'),
    ];
    final subtitles = [
      _tr(
        context,
        '수집, 복습, 문제 풀이를 한 흐름에서 이어가는 학습 공간입니다.',
        'A single workspace for collection, review, and exam practice.',
      ),
      _tr(
        context,
        '덱별 필터와 검색으로 카드를 빠르게 정리할 수 있어요.',
        'Filter by deck, search quickly, and keep favorite cards close at hand.',
      ),
      _tr(
        context,
        '지금 복습 대기 중인 카드가 ${dueWords.length}장 있습니다.',
        'You currently have ${dueWords.length} cards waiting for review.',
      ),
      _tr(
        context,
        '현재 학습 언어에 맞는 기사와 자료를 열어 실제 문맥으로 이동합니다.',
        'Open reading and media-based study material for your current language routine.',
      ),
      _tr(
        context,
        '최근 활동을 확인하고 다음 루틴을 데이터로 조정해 보세요.',
        'Check recent activity and adjust your next routine from the data.',
      ),
    ];
    final useRail = layout.isExpanded;
    final headerActions = _HeaderActions(
      onOpenExamBuilder: widget.settings.isGermanMode
          ? _openGeneratedExamSheet
          : null,
      onOpenSettings: _openSettingsSheet,
    );
    final mainPage = _buildPage(
      words: words,
      dueWords: dueWords,
      todayRecommendedWords: todayRecommendedWords,
    );
    final mainContent = _ContentCard(
      title: titles[_selectedIndex],
      subtitle: subtitles[_selectedIndex],
      badge: _badgeLabel(wordCount: words.length, dueCount: dueWords.length),
      headerActions: headerActions,
      child: mainPage,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: layout.isCompact
          ? FloatingActionButton(
              onPressed: _openAddWordSheet,
              child: const Icon(Icons.add_rounded),
            )
          : FloatingActionButton.extended(
              onPressed: _openAddWordSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(_tr(context, '단어 추가', 'Add word')),
            ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: _tr(context, '홈', 'Home'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.layers_outlined),
                  selectedIcon: Icon(Icons.layers_rounded),
                  label: _tr(context, '컬렉션', 'Library'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt_rounded),
                  label: _tr(context, '복습', 'Review'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: _tr(context, '실전', 'Immersion'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: _tr(context, '통계', 'Insights'),
                ),
              ],
            ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.pagePadding,
            layout.pagePadding,
            layout.pagePadding,
            0,
          ),
          child: useRail
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Row(
                      children: [
                        _RailCard(
                          selectedIndex: _selectedIndex,
                          dueCount: dueWords.length,
                          onSelected: _selectTab,
                          width: layout.maxWidth >= 1320 ? 272 : 244,
                        ),
                        const SizedBox(width: 18),
                        Expanded(child: mainContent),
                      ],
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: layout.maxReadableWidth,
                    ),
                    child: _MobilePageLayout(
                      title: titles[_selectedIndex],
                      subtitle: subtitles[_selectedIndex],
                      badge: _badgeLabel(
                        wordCount: words.length,
                        dueCount: dueWords.length,
                      ),
                      headerActions: headerActions,
                      child: mainPage,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required List<VocabWord> words,
    required List<VocabWord> dueWords,
    required List<VocabWord> todayRecommendedWords,
  }) {
    switch (_selectedIndex) {
      case 0:
        return _DashboardPage(
          words: words,
          dueWords: dueWords,
          todayRecommendedWords: todayRecommendedWords,
          onOpenSection: _selectTab,
          onBookmarkToggle: widget.repository.toggleBookmark,
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
          onOpenCoach: _openWordCoach,
          onAddDailyWord: _openDailyRecommendationSheet,
          onOpenDailyRecommendations: _openDailyRecommendationsPage,
          onOpenExamLab: widget.settings.isGermanMode
              ? _openGeneratedExamSheet
              : null,
        );
      case 1:
        final allDecks = <String>{
          'All',
          ...words.map((word) => word.deck),
        }.toList()..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));
        final query = _searchController.text.trim().toLowerCase();
        final filtered = words.where((word) {
          final matchesDeck =
              _selectedDeck == 'All' || _selectedDeck == word.deck;
          final matchesQuery =
              query.isEmpty ||
              word.german.toLowerCase().contains(query) ||
              word.meaningKo.toLowerCase().contains(query) ||
              word.meaningEn.toLowerCase().contains(query);
          return matchesDeck && matchesQuery;
        }).toList();

        return _CollectionPage(
          words: filtered,
          decks: allDecks,
          selectedDeck: _selectedDeck,
          searchController: _searchController,
          onSearchChanged: (_) => setState(() {}),
          onDeckSelected: (deck) => setState(() => _selectedDeck = deck),
          onClearSearch: () {
            if (_searchController.text.isEmpty) {
              return;
            }
            setState(_searchController.clear);
          },
          onResetFilters: () {
            if (_searchController.text.isEmpty && _selectedDeck == 'All') {
              return;
            }
            setState(() {
              _searchController.clear();
              _selectedDeck = 'All';
            });
          },
          onBookmarkToggle: widget.repository.toggleBookmark,
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
          onOpenCoach: _openWordCoach,
          primaryMeaningOf: _primaryMeaning,
          secondaryMeaningOf: _secondaryMeaning,
        );
      case 2:
        return _PracticePage(
          dueWords: dueWords,
          revealAnswer: _revealAnswer,
          onReveal: () => setState(() => _revealAnswer = true),
          onReview: (word, remembered) async {
            await widget.repository.reviewWord(word, remembered: remembered);
            if (!mounted) {
              return;
            }
            setState(() {
              _revealAnswer = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  remembered
                      ? 'Moved ${word.german} to the next interval.'
                      : 'Queued ${word.german} for a closer review.',
                ),
              ),
            );
          },
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
          onOpenCoach: _openWordCoach,
        );
      case 3:
        return ImmersionHubPage(
          settings: widget.settings,
          repository: widget.immersionRepository,
          dictionaryRepository: widget.dictionaryRepository,
          studyRepository: widget.repository,
          newsFeedRepository: widget.newsFeedRepository,
          pronunciationService: widget.pronunciationService,
          knownWords: words,
        );
      default:
        return _InsightsPage(repository: widget.repository, words: words);
    }
  }

  Future<void> _openAddWordSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: AddWordSheet(
          dictionaryRepository: widget.dictionaryRepository,
          repository: widget.repository,
          pronunciationService: widget.pronunciationService,
          settings: widget.settings,
        ),
      ),
    );
  }

  Future<void> _openDailyRecommendationSheet() {
    final title = _tr(context, '오늘 추천에 저장', 'Add to today\'s picks');
    final subtitle = _tr(
      context,
      '사전 자동 채움으로 추천 단어를 저장하면 홈의 오늘 추천 영역에 바로 나타납니다.',
      'Save a word with autofill and it will appear immediately in the daily picks area on the dashboard.',
    );
    final submitLabel = _tr(context, '추천 단어 저장', 'Save daily pick');

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: AddWordSheet(
          dictionaryRepository: widget.dictionaryRepository,
          repository: widget.repository,
          pronunciationService: widget.pronunciationService,
          settings: widget.settings,
          defaultDeck: 'Daily Picks',
          initialIsDailyRecommendation: true,
          title: title,
          subtitle: subtitle,
          submitLabel: submitLabel,
        ),
      ),
    );
  }

  Future<void> _openDailyRecommendationsPage() {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DailyRecommendationsPage(
          repository: widget.repository,
          dictionaryRepository: widget.dictionaryRepository,
          pronunciationService: widget.pronunciationService,
          settings: widget.settings,
        ),
      ),
    );
  }

  Future<void> _speakWord(VocabWord word) async {
    await _speakText(
      word.german,
      locale: _voiceLocaleCodeForWord(word),
      errorMessage: _tr(
        context,
        '단어 음성을 재생하지 못했어요. 기기에 독일어 TTS 음성이 설치되어 있는지 확인해 주세요.',
        'Could not play the word audio. Check that a German TTS voice is installed on this device.',
      ),
    );
  }

  Future<void> _speakExample(VocabWord word) async {
    await _speakText(
      word.exampleSentence,
      locale: _voiceLocaleCodeForWord(word),
      errorMessage: _tr(
        context,
        '예문 음성을 재생하지 못했어요. 기기에 독일어 TTS 음성이 설치되어 있는지 확인해 주세요.',
        'Could not play the example audio. Check that a German TTS voice is installed on this device.',
      ),
    );
  }

  Future<void> _speakText(
    String text, {
    String? locale,
    required String errorMessage,
  }) async {
    try {
      await widget.pronunciationService.speak(text, locale: locale);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _openWordCoach(VocabWord word) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: WordCoachSheet(
          word: word,
          pronunciationService: widget.pronunciationService,
          assessmentService: widget.pronunciationAssessmentService,
          studyCoachService: widget.studyCoachService,
          appLanguage: widget.settings.appLanguage,
          aiProviderPreference: widget.settings.aiProviderPreference,
        ),
      ),
    );
  }

  Future<void> _openSettingsSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: AppSettingsSheet(
          initialSettings: widget.settings,
          repository: widget.appSettingsRepository,
          aiConfigured: widget.studyCoachService.isConfigured,
          activeProviderLabel: widget.studyCoachService.providerLabel,
        ),
      ),
    );
  }

  Future<void> _openGeneratedExamSheet() {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExamPracticePage(
          repository: widget.repository,
          settings: widget.settings,
          pronunciationService: widget.pronunciationService,
          assessmentService: widget.pronunciationAssessmentService,
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _revealAnswer = false;
      }
    });
  }

  String _badgeLabel({required int wordCount, required int dueCount}) {
    switch (_selectedIndex) {
      case 2:
        return _tr(context, '오늘 복습 $dueCount개', 'Due today $dueCount');
      case 3:
        return _tr(
          context,
          '실전 자료 ${immersionLearningResources.length}개',
          'Immersion ${immersionLearningResources.length}',
        );
      default:
        return '${widget.settings.studyLanguage.englishLabel} words $wordCount';
    }
  }

  String _primaryMeaning(VocabWord word) {
    return widget.settings.appLanguage.copy(
      korean: word.meaningKo,
      english: word.meaningEn,
    );
  }

  String _secondaryMeaning(VocabWord word) {
    return widget.settings.appLanguage.copy(
      korean: word.meaningEn,
      english: word.meaningKo,
    );
  }

  static int _sortWords(VocabWord a, VocabWord b) {
    final bookmark = (b.isBookmarked ? 1 : 0).compareTo(a.isBookmarked ? 1 : 0);
    if (bookmark != 0) {
      return bookmark;
    }
    final review = (a.nextReviewAt ?? 0).compareTo(b.nextReviewAt ?? 0);
    if (review != 0) {
      return review;
    }
    return a.german.compareTo(b.german);
  }

  static List<VocabWord> _dueWords(List<VocabWord> words) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final due = words
        .where((word) => word.nextReviewAt == null || word.nextReviewAt! <= now)
        .toList();
    due.sort((a, b) => (a.nextReviewAt ?? 0).compareTo(b.nextReviewAt ?? 0));
    return due;
  }

  static List<VocabWord> _todayRecommendedWords(List<VocabWord> words) {
    final todayKey = dailyRecommendationDateKey(DateTime.now());
    final recommended = words
        .where(
          (word) =>
              word.isDailyRecommendation &&
              word.dailyRecommendationDateKey == todayKey,
        )
        .toList();
    recommended.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recommended;
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.words,
    required this.dueWords,
    required this.todayRecommendedWords,
    required this.onOpenSection,
    required this.onBookmarkToggle,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
    required this.onAddDailyWord,
    required this.onOpenDailyRecommendations,
    this.onOpenExamLab,
  });

  final List<VocabWord> words;
  final List<VocabWord> dueWords;
  final List<VocabWord> todayRecommendedWords;
  final ValueChanged<int> onOpenSection;
  final Future<void> Function(VocabWord word) onBookmarkToggle;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;
  final Future<void> Function(VocabWord word) onOpenCoach;
  final Future<void> Function() onAddDailyWord;
  final Future<void> Function() onOpenDailyRecommendations;
  final Future<void> Function()? onOpenExamLab;

  @override
  Widget build(BuildContext context) {
    final showHero = MediaQuery.sizeOf(context).width >= 720;
    final deckSummaries = _deckSummaries(words);
    final average = words.isEmpty
        ? 0
        : ((words.fold<int>(0, (sum, word) => sum + word.mastery) /
                      (words.length * 5)) *
                  100)
              .round();
    final bookmarks = words.where((word) => word.isBookmarked).length;
    final dailyRemainingCount = math.max(
      0,
      dailyGermanRecommendationTargetCount - todayRecommendedWords.length,
    );
    final modules = [
      _DashboardModule(
        tabIndex: 1,
        icon: Icons.layers_rounded,
        label: _tr(context, '컬렉션', 'Library'),
        value: _tr(context, '${words.length}장', '${words.length}'),
        title: _tr(context, '단어 라이브러리', 'Word library'),
        body: _tr(
          context,
          '덱과 검색으로 카드를 정리하고 다시 찾을 수 있어요.',
          'Organize cards by deck and find them again fast.',
        ),
        color: AppColors.teal,
      ),
      _DashboardModule(
        tabIndex: 2,
        icon: Icons.bolt_rounded,
        label: _tr(context, '복습', 'Review'),
        value: _tr(context, '${dueWords.length}개', '${dueWords.length}'),
        title: _tr(context, '리뷰 세션', 'Review session'),
        body: _tr(
          context,
          '지금 다시 볼 카드부터 빠르게 이어서 복습합니다.',
          'Continue from the cards you should see again right now.',
        ),
        color: AppColors.coral,
      ),
      _DashboardModule(
        tabIndex: 3,
        icon: Icons.explore_rounded,
        label: _tr(context, '실전', 'Immersion'),
        value: _tr(
          context,
          '${immersionLearningResources.length}개',
          '${immersionLearningResources.length}',
        ),
        title: _tr(context, '실전 독일어', 'Immersion hub'),
        body: _tr(
          context,
          '뉴스와 자료를 눌러 실제 문맥 속 단어와 바로 연결됩니다.',
          'Open news and resources that connect words to real contexts.',
        ),
        color: AppColors.ink,
      ),
      _DashboardModule(
        tabIndex: 4,
        icon: Icons.insights_rounded,
        label: _tr(context, '통계', 'Insights'),
        value: '$average%',
        title: _tr(context, '학습 인사이트', 'Study insights'),
        body: _tr(
          context,
          '리듬과 약한 덱을 확인하며 다음 루틴을 정리할 수 있어요.',
          'Check rhythm and weaker decks before planning the next routine.',
        ),
        color: AppColors.gold,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        if (showHero) ...[
          _HeroBanner(
            color: AppColors.ink,
            eyebrow: 'Study rhythm',
            title: _tr(
              context,
              'Guten Tag.\n오늘의 독일어 흐름을 이어가 보세요.',
              'Guten Tag.\nKeep your German flow going.',
            ),
            body: _tr(
              context,
              '같은 로컬 학습 공간에서 단어를 쌓고, 복습을 이어가고, 읽기·듣기·말하기 문제까지 바로 풀 수 있게 구성했습니다.',
              'Build cards, continue reviews, and move into reading, listening, and speaking practice from the same local learning workspace.',
            ),
          ),
          const SizedBox(height: 20),
        ],
        _SectionTitle(
          title: _tr(context, '빠른 이동', 'Quick access'),
          subtitle: _tr(
            context,
            '필요한 흐름을 누르면 해당 정보 화면으로 바로 이어집니다.',
            'Jump straight into the part of the routine you want to work on.',
          ),
        ),
        const SizedBox(height: 14),
        _AdaptiveCardGrid(
          minTileWidth: 148,
          maxColumns: 4,
          children: modules
              .map(
                (module) => _DashboardModuleCard(
                  module: module,
                  onTap: () => onOpenSection(module.tabIndex),
                ),
              )
              .toList(),
        ),
        if (onOpenExamLab != null) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onOpenExamLab,
              icon: const Icon(Icons.headset_mic_rounded),
              label: Text(_tr(context, '읽기·듣기·말하기 연습 열기', 'Open practice lab')),
              style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _AdaptiveCardGrid(
          minTileWidth: 160,
          maxColumns: 4,
          children: [
            _MetricTile(
              label: _tr(context, '전체 단어', 'Total words'),
              value: '${words.length}',
              hint: _tr(context, '수집한 카드', 'Saved cards'),
              color: AppColors.ink,
            ),
            _MetricTile(
              label: _tr(context, '오늘 복습', 'Due today'),
              value: '${dueWords.length}',
              hint: _tr(context, '지금 다시 볼 카드', 'Cards to review now'),
              color: AppColors.coral,
            ),
            _MetricTile(
              label: _tr(context, '오늘 추천', 'Daily picks'),
              value: '${todayRecommendedWords.length}',
              hint: _tr(
                context,
                '$dailyGermanRecommendationTargetCount개 목표',
                'Target $dailyGermanRecommendationTargetCount',
              ),
              color: AppColors.gold,
            ),
            _MetricTile(
              label: _tr(context, '북마크', 'Bookmarks'),
              value: '$bookmarks',
              hint: _tr(context, '집중 카드', 'Focus cards'),
              color: AppColors.teal,
            ),
            _MetricTile(
              label: _tr(context, '숙련도', 'Mastery'),
              value: '$average%',
              hint: _tr(context, '평균 진행률', 'Average progress'),
              color: AppColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionTitle(
          title: _tr(context, '오늘의 추천 단어', 'Daily picks'),
          subtitle: _tr(
            context,
            '전용 페이지에서 오늘의 독일어 추천 단어를 준비하고, Gemini 설명과 독일어 TTS로 확인해 보세요.',
            'Open the dedicated page to prepare and review today\'s German words with Gemini notes and German TTS.',
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onOpenDailyRecommendations,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(
                dailyRemainingCount == 0
                    ? _tr(context, '오늘 추천 준비 완료', 'Daily target ready')
                    : _tr(
                        context,
                        '오늘 추천 페이지 열기 ($dailyRemainingCount개 남음)',
                        'Open daily page ($dailyRemainingCount left)',
                      ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAddDailyWord,
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(_tr(context, '직접 단어 추가', 'Add one manually')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: BorderSide(color: AppColors.ink.withValues(alpha: 0.14)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (todayRecommendedWords.isEmpty)
          _EmptyPanel(
            title: _tr(context, '아직 오늘 추천 단어가 없어요.', 'No daily picks yet.'),
            message: _tr(
              context,
              '오늘 추천 페이지를 열어 Gemini 설명과 독일어 음성이 들어간 세트를 준비해 보세요.',
              'Open the daily page to prepare a focused set with Gemini notes and a German voice.',
            ),
          )
        else
          ...todayRecommendedWords.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FocusWordTile(
                word: word,
                onBookmark: () => onBookmarkToggle(word),
                onSpeakWord: () => onSpeakWord(word),
                onSpeakExample: () => onSpeakExample(word),
                onOpenCoach: () => onOpenCoach(word),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _SectionTitle(
          title: _tr(context, '오늘의 포커스', 'Today\'s focus'),
          subtitle: _tr(
            context,
            '지금 꺼내 보면 좋은 단어부터 먼저 정리했습니다.',
            'The best cards to pull out right now are listed first.',
          ),
        ),
        const SizedBox(height: 14),
        if (dueWords.isEmpty)
          _EmptyPanel(
            title: _tr(
              context,
              '오늘 복습 큐가 비어 있어요.',
              'Your review queue is clear for now.',
            ),
            message: _tr(
              context,
              '새 단어를 추가하거나 컬렉션에서 북마크 카드를 더 쌓아보세요.',
              'Add new words or bookmark more cards from the library.',
            ),
          )
        else
          ...dueWords
              .take(3)
              .map(
                (word) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FocusWordTile(
                    word: word,
                    onBookmark: () => onBookmarkToggle(word),
                    onSpeakWord: () => onSpeakWord(word),
                    onSpeakExample: () => onSpeakExample(word),
                    onOpenCoach: () => onOpenCoach(word),
                  ),
                ),
              ),
        const SizedBox(height: 12),
        _SectionTitle(
          title: _tr(context, '덱 스냅샷', 'Deck snapshot'),
          subtitle: _tr(
            context,
            '주제별 진행률을 빠르게 훑어보고 약한 덱을 골라 복습할 수 있습니다.',
            'Scan topic progress quickly and pick weaker decks for review.',
          ),
        ),
        const SizedBox(height: 14),
        ...deckSummaries.map(
          (deck) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DeckProgressTile(summary: deck),
          ),
        ),
      ],
    );
  }
}

class _CollectionPage extends StatelessWidget {
  const _CollectionPage({
    required this.words,
    required this.decks,
    required this.selectedDeck,
    required this.searchController,
    required this.onSearchChanged,
    required this.onDeckSelected,
    required this.onClearSearch,
    required this.onResetFilters,
    required this.onBookmarkToggle,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
    required this.primaryMeaningOf,
    required this.secondaryMeaningOf,
  });

  final List<VocabWord> words;
  final List<String> decks;
  final String selectedDeck;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDeckSelected;
  final VoidCallback onClearSearch;
  final VoidCallback onResetFilters;
  final Future<void> Function(VocabWord word) onBookmarkToggle;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;
  final Future<void> Function(VocabWord word) onOpenCoach;
  final String Function(VocabWord word) primaryMeaningOf;
  final String Function(VocabWord word) secondaryMeaningOf;

  @override
  Widget build(BuildContext context) {
    final showHero = MediaQuery.sizeOf(context).width >= 720;
    final hasSearchText = searchController.text.trim().isNotEmpty;
    final hasActiveFilters = hasSearchText || selectedDeck != 'All';

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        if (showHero) ...[
          _HeroBanner(
            color: AppColors.teal,
            eyebrow: 'Word library',
            title: _tr(
              context,
              '단어 컬렉션을 덱별로\n차분하게 쌓아보세요.',
              'Build your library\none deck at a time.',
            ),
            body: _tr(
              context,
              '검색과 덱 필터로 원하는 주제를 빠르게 찾고, 중요한 카드는 북마크로 다시 복습 큐에 불러올 수 있습니다.',
              'Search and filter by deck, then pull important cards back into review with bookmarks.',
            ),
          ),
          const SizedBox(height: 20),
        ],
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: _tr(
              context,
              '독일어, 한국어 뜻, 영어 뜻으로 검색',
              'Search by word, Korean meaning, or English meaning',
            ),
            suffixIcon: hasSearchText
                ? IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: _tr(context, '검색어 지우기', 'Clear search'),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: decks
              .map(
                (deck) => ChoiceChip(
                  label: Text(deck),
                  selected: deck == selectedDeck,
                  onSelected: (_) => onDeckSelected(deck),
                ),
              )
              .toList(),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(_tr(context, '검색과 덱 초기화', 'Reset filters')),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (words.isEmpty)
          _EmptyPanel(
            title: _tr(
              context,
              '조건에 맞는 단어가 없어요.',
              'No words match these filters.',
            ),
            message: _tr(
              context,
              '검색어를 바꾸거나 다른 덱을 선택해 보세요.',
              'Try a different search term or choose another deck.',
            ),
          )
        else
          ...words.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CollectionWordTile(
                word: word,
                primaryMeaning: primaryMeaningOf(word),
                secondaryMeaning: secondaryMeaningOf(word),
                onBookmark: () => onBookmarkToggle(word),
                onSpeakWord: () => onSpeakWord(word),
                onSpeakExample: () => onSpeakExample(word),
                onOpenCoach: () => onOpenCoach(word),
              ),
            ),
          ),
      ],
    );
  }
}

class _PracticePage extends StatelessWidget {
  const _PracticePage({
    required this.dueWords,
    required this.revealAnswer,
    required this.onReveal,
    required this.onReview,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
  });

  final List<VocabWord> dueWords;
  final bool revealAnswer;
  final VoidCallback onReveal;
  final Future<void> Function(VocabWord word, bool remembered) onReview;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;
  final Future<void> Function(VocabWord word) onOpenCoach;

  @override
  Widget build(BuildContext context) {
    final showHero = MediaQuery.sizeOf(context).width >= 720;
    if (dueWords.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
        children: [
          if (showHero) ...[
            _HeroBanner(
              color: AppColors.gold,
              eyebrow: 'Review queue',
              title: _tr(
                context,
                '오늘 복습 큐를\n깨끗하게 비웠습니다.',
                'Your review queue\nis all clear.',
              ),
              body: _tr(
                context,
                '새 단어를 추가하면 즉시 복습 큐에 들어가도록 구성해 두었습니다.',
                'New words are set to enter the review queue immediately.',
              ),
            ),
            const SizedBox(height: 20),
          ],
          _EmptyPanel(
            title: _tr(
              context,
              '지금은 복습할 카드가 없어요.',
              'There are no cards to review right now.',
            ),
            message: _tr(
              context,
              '조금 있다가 다시 오거나 새 단어를 넣어 다음 세션을 시작해 보세요.',
              'Come back a little later or add new words to start the next session.',
            ),
          ),
        ],
      );
    }

    final current = dueWords.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        if (showHero) ...[
          _HeroBanner(
            color: AppColors.coral,
            eyebrow: 'Active recall',
            title: _tr(
              context,
              '답을 보기 전에 먼저\n뜻과 장면을 떠올려 보세요.',
              'Recall the meaning\nbefore revealing the answer.',
            ),
            body: _tr(
              context,
              '기억 여부에 따라 복습 간격을 자동으로 다시 배치합니다. 남은 복습은 ${dueWords.length}개입니다.',
              'Review spacing is updated automatically from your answer. ${dueWords.length} cards remain.',
            ),
          ),
          const SizedBox(height: 20),
        ],
        _PracticeCard(
          word: current,
          revealAnswer: revealAnswer,
          onReveal: onReveal,
          onForgot: () => onReview(current, false),
          onRemembered: () => onReview(current, true),
          onSpeakWord: () => onSpeakWord(current),
          onSpeakExample: () => onSpeakExample(current),
          onOpenCoach: () => onOpenCoach(current),
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: _tr(context, '다음 카드', 'Next cards'),
          subtitle: _tr(
            context,
            '곧 이어서 복습하게 될 단어들입니다.',
            'These cards are coming up next in the review queue.',
          ),
        ),
        const SizedBox(height: 14),
        ...dueWords
            .skip(1)
            .take(4)
            .map(
              (word) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QueueTile(word: word),
              ),
            ),
      ],
    );
  }
}

class _InsightsPage extends StatelessWidget {
  const _InsightsPage({required this.repository, required this.words});

  final StudyRepository repository;
  final List<VocabWord> words;

  @override
  Widget build(BuildContext context) {
    final showHero = MediaQuery.sizeOf(context).width >= 720;
    return StreamBuilder<List<StudySession>>(
      stream: repository.watchStudySessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <StudySession>[];
        final activity = _weeklyActivity(
          sessions,
          appLanguage: AppSettingsScope.of(context).appLanguage,
        );
        final reviews = activity.fold<int>(0, (sum, day) => sum + day.reviews);
        final minutes = activity.fold<int>(0, (sum, day) => sum + day.minutes);
        final mastered = words.where((word) => word.mastery >= 4).length;
        final weakestDeck = (_deckSummaries(
          words,
        )..sort((a, b) => a.ratio.compareTo(b.ratio))).take(3).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
          children: [
            if (showHero) ...[
              _HeroBanner(
                color: AppColors.gold,
                eyebrow: 'Learning pulse',
                title: _tr(
                  context,
                  '조용하지만 분명하게,\n학습 리듬을 숫자로 확인하세요.',
                  'Quiet but clear,\ncheck your learning rhythm in numbers.',
                ),
                body: _tr(
                  context,
                  '최근 7일 학습량과 덱별 숙련도를 함께 보며 무엇을 더 끌어올려야 할지 빠르게 판단할 수 있습니다.',
                  'Compare the last 7 days of activity and deck mastery to see what needs attention next.',
                ),
              ),
              const SizedBox(height: 20),
            ],
            _AdaptiveCardGrid(
              minTileWidth: 170,
              maxColumns: 4,
              children: [
                _MetricTile(
                  label: _tr(context, '이번 주 복습', 'Reviews this week'),
                  value: '$reviews',
                  hint: _tr(context, '최근 7일 리뷰 수', 'Last 7 days'),
                  color: AppColors.ink,
                ),
                _MetricTile(
                  label: _tr(context, '학습 시간', 'Study time'),
                  value: _tr(context, '$minutes분', '$minutes min'),
                  hint: _tr(context, '최근 7일 누적', 'Last 7 days total'),
                  color: AppColors.teal,
                ),
                _MetricTile(
                  label: _tr(context, '고숙련', 'Strong cards'),
                  value: '$mastered',
                  hint: _tr(context, '숙련도 4 이상', 'Mastery 4+'),
                  color: AppColors.gold,
                ),
                _MetricTile(
                  label: _tr(context, '연속 학습', 'Streak'),
                  value: _tr(
                    context,
                    '${_streak(sessions)}일',
                    '${_streak(sessions)} days',
                  ),
                  hint: _tr(context, '오늘까지 이어진 루틴', 'Up to today'),
                  color: AppColors.coral,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: _tr(context, '최근 7일 활동', 'Last 7 days'),
              subtitle: _tr(
                context,
                '복습 수와 학습 시간을 가볍게 비교할 수 있는 주간 뷰입니다.',
                'A simple weekly view for comparing review counts and study time.',
              ),
            ),
            const SizedBox(height: 14),
            _ActivityChart(days: activity),
            const SizedBox(height: 24),
            _SectionTitle(
              title: _tr(context, '보강하면 좋은 덱', 'Decks to reinforce'),
              subtitle: _tr(
                context,
                '평균 숙련도가 낮은 순서대로 정렬했습니다.',
                'Ordered from the lowest average mastery.',
              ),
            ),
            const SizedBox(height: 14),
            ...weakestDeck.map(
              (deck) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeckProgressTile(summary: deck),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({
    required this.selectedIndex,
    required this.dueCount,
    required this.onSelected,
    required this.width,
  });

  final int selectedIndex;
  final int dueCount;
  final ValueChanged<int> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            title: const Text(
              'Deutsch Flow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            subtitle: Text(_tr(context, '언어 학습 루틴', 'language study routine')),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              backgroundColor: Colors.transparent,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home_rounded),
                  label: Text(_tr(context, '홈', 'Home')),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.layers_rounded),
                  label: Text(_tr(context, '컬렉션', 'Library')),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    label: Text('$dueCount'),
                    isLabelVisible: dueCount > 0,
                    child: const Icon(Icons.bolt_rounded),
                  ),
                  label: Text(_tr(context, '복습', 'Review')),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_rounded),
                  label: Text(_tr(context, '실전', 'Immersion')),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: Text(_tr(context, '통계', 'Insights')),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              _tr(
                context,
                '새 단어를 추가하면 즉시 복습 큐에 들어가도록 설정해 두었습니다.',
                'New words are configured to enter the review queue right away.',
              ),
              style: const TextStyle(height: 1.5, color: Color(0xFF5F6F7C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.headerActions,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Widget headerActions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final header = <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: layout.displayTitleSize,
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        ];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.07),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(layout.panelRadius),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                layout.cardPadding,
                layout.cardPadding,
                layout.cardPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (layout.maxWidth < 560) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: header,
                          ),
                        ),
                        const SizedBox(width: 12),
                        headerActions,
                      ],
                    ),
                    const SizedBox(height: 14),
                    _HeaderBadge(badge: badge),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: header,
                          ),
                        ),
                        const SizedBox(width: 16),
                        headerActions,
                        const SizedBox(width: 12),
                        _HeaderBadge(badge: badge),
                      ],
                    ),
                  const SizedBox(height: 18),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobilePageLayout extends StatelessWidget {
  const _MobilePageLayout({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.headerActions,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Widget headerActions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageIntroHeader(
          title: title,
          subtitle: subtitle,
          badge: badge,
          headerActions: headerActions,
        ),
        const SizedBox(height: 18),
        Expanded(child: child),
      ],
    );
  }
}

class _PageIntroHeader extends StatelessWidget {
  const _PageIntroHeader({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.headerActions,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Widget headerActions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            layout.isCompact ? 2 : 4,
            6,
            layout.isCompact ? 2 : 4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (layout.maxWidth < 420) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: layout.isCompact ? 26 : 30),
                      ),
                    ),
                    const SizedBox(width: 10),
                    headerActions,
                  ],
                ),
                const SizedBox(height: 12),
                _MobileHeaderBadge(label: badge),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: layout.isCompact ? 26 : 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    headerActions,
                    const SizedBox(width: 12),
                    _MobileHeaderBadge(label: badge),
                  ],
                ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.isTablet ? 620 : double.infinity,
                ),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: layout.isCompact ? 15 : 16,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.onOpenSettings, this.onOpenExamBuilder});

  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenExamBuilder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onOpenExamBuilder != null)
          IconButton.filledTonal(
            onPressed: onOpenExamBuilder,
            tooltip: _tr(context, '읽기·듣기·말하기 연습', 'Practice lab'),
            icon: const Icon(Icons.headset_mic_rounded),
          ),
        IconButton.filledTonal(
          onPressed: onOpenSettings,
          tooltip: _tr(context, '학습 설정', 'Study settings'),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _BackdropOrbs extends StatelessWidget {
  const _BackdropOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: -30,
            child: _orb(AppColors.teal.withValues(alpha: 0.18), 220),
          ),
          Positioned(
            right: -40,
            top: 80,
            child: _orb(AppColors.coral.withValues(alpha: 0.14), 180),
          ),
          Positioned(
            right: 60,
            bottom: 80,
            child: _orb(AppColors.gold.withValues(alpha: 0.18), 240),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 10)],
      ),
    );
  }
}

class _AdaptiveCardGrid extends StatelessWidget {
  const _AdaptiveCardGrid({
    required this.children,
    this.minTileWidth = 180,
    this.maxColumns = 4,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final columns = layout.columnsFor(
          minTileWidth: minTileWidth,
          maxColumns: maxColumns,
          spacing: spacing,
        );
        final itemWidth = layout.itemWidth(columns: columns, spacing: spacing);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.badge});

  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        badge,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _MobileHeaderBadge extends StatelessWidget {
  const _MobileHeaderBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.tabIndex,
    required this.icon,
    required this.label,
    required this.value,
    required this.title,
    required this.body,
    required this.color,
  });

  final int tabIndex;
  final IconData icon;
  final String label;
  final String value;
  final String title;
  final String body;
  final Color color;
}

class _DashboardModuleCard extends StatelessWidget {
  const _DashboardModuleCard({required this.module, required this.onTap});

  final _DashboardModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 210;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(compact ? 22 : 26),
            child: Ink(
              padding: EdgeInsets.all(compact ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(compact ? 22 : 26),
                border: Border.all(color: module.color.withValues(alpha: 0.16)),
              ),
              child: SizedBox(
                height: compact ? 150 : 178,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: compact ? 16 : 20,
                          backgroundColor: module.color.withValues(alpha: 0.14),
                          child: Icon(
                            module.icon,
                            color: module.color,
                            size: compact ? 18 : 22,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 8 : 10,
                            vertical: compact ? 5 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: module.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            module.label,
                            style: TextStyle(
                              color: module.color,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 12 : 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 14),
                    Text(
                      module.value,
                      style: TextStyle(
                        fontSize: compact ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.title,
                      style: TextStyle(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: compact ? 6 : 8),
                    Expanded(
                      child: Text(
                        module.body,
                        style: TextStyle(
                          height: 1.45,
                          color: const Color(0xFF5F707F),
                          fontSize: compact ? 13 : 14,
                        ),
                        maxLines: compact ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _tr(context, '열어서 보기', 'Open'),
                          style: TextStyle(
                            color: module.color,
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 13 : 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: compact ? 16 : 18,
                          color: module.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeckSummary {
  const _DeckSummary(
    this.name,
    this.total,
    this.bookmarks,
    this.ratio,
    this.color,
  );
  final String name;
  final int total;
  final int bookmarks;
  final double ratio;
  final Color color;
}

class _DayActivity {
  const _DayActivity(this.label, this.reviews, this.minutes);
  final String label;
  final int reviews;
  final int minutes;
}

List<_DeckSummary> _deckSummaries(List<VocabWord> words) {
  const colors = [
    AppColors.ink,
    AppColors.teal,
    AppColors.coral,
    AppColors.gold,
  ];
  final grouped = <String, List<VocabWord>>{};
  for (final word in words) {
    grouped.putIfAbsent(word.deck, () => <VocabWord>[]).add(word);
  }

  final keys = grouped.keys.toList()..sort();
  return [
    for (var i = 0; i < keys.length; i++)
      _DeckSummary(
        keys[i],
        grouped[keys[i]]!.length,
        grouped[keys[i]]!.where((word) => word.isBookmarked).length,
        grouped[keys[i]]!.fold<int>(0, (sum, word) => sum + word.mastery) /
            (grouped[keys[i]]!.length * 5),
        colors[i % colors.length],
      ),
  ];
}

List<_DayActivity> _weeklyActivity(
  List<StudySession> sessions, {
  required AppLanguage appLanguage,
}) {
  final now = DateTime.now();
  return List.generate(7, (index) {
    final day = DateUtils.dateOnly(now.subtract(Duration(days: 6 - index)));
    final related = sessions.where(
      (session) =>
          DateUtils.dateOnly(
            DateTime.fromMillisecondsSinceEpoch(session.studiedAt),
          ) ==
          day,
    );
    return _DayActivity(
      _weekday(day.weekday, appLanguage: appLanguage),
      related.fold<int>(0, (sum, item) => sum + item.reviewedCount),
      related.fold<int>(0, (sum, item) => sum + item.minutesSpent),
    );
  });
}

int _streak(List<StudySession> sessions) {
  final days = sessions
      .map(
        (session) => DateUtils.dateOnly(
          DateTime.fromMillisecondsSinceEpoch(session.studiedAt),
        ),
      )
      .toSet();
  var cursor = DateUtils.dateOnly(DateTime.now());
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

String _weekday(int weekday, {required AppLanguage appLanguage}) {
  const koreanLabels = ['월', '화', '수', '목', '금', '토', '일'];
  const englishLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final index = (weekday - 1).clamp(0, 6);
  return appLanguage.copy(
    korean: koreanLabels[index],
    english: englishLabels[index],
  );
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final Color color;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final compact = layout.maxWidth < 720;

        return Container(
          padding: EdgeInsets.all(compact ? 18 : layout.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              compact ? 24 : layout.panelRadius,
            ),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: layout.sectionGap),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 21 : layout.heroTitleSize,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.isExpanded ? 640 : double.infinity,
                ),
                child: Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: compact ? 14 : layout.bodySize,
                    height: 1.55,
                  ),
                  maxLines: compact ? 3 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.color,
  });

  final String label;
  final String value;
  final String hint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 190;

        return Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(compact ? 20 : 26),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: compact ? 18 : 22,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: color,
                  size: compact ? 18 : 22,
                ),
              ),
              SizedBox(height: compact ? 10 : 14),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF617180),
                  fontSize: compact ? 13 : 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: compact ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: TextStyle(
                  color: const Color(0xFF617180),
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: layout.isCompact ? 20 : 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: layout.isCompact ? 13 : 14,
                height: 1.5,
                color: const Color(0xFF617180),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.ink.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.ink,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: layout.isCompact ? 20 : 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: layout.bodySize,
                  height: 1.55,
                  color: const Color(0xFF617180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GrammarNotePanel extends StatelessWidget {
  const _GrammarNotePanel({
    required this.note,
    this.title,
    this.color = AppColors.teal,
  });

  final String note;
  final String? title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? _tr(context, '문법 메모', 'Grammar notes'),
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              height: 1.5,
              color: Color(0xFF566978),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusWordTile extends StatelessWidget {
  const _FocusWordTile({
    required this.word,
    required this.onBookmark,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
  });

  final VocabWord word;
  final VoidCallback onBookmark;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;
  final Future<void> Function() onOpenCoach;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final primaryMeaning = _uiPrimaryMeaning(context, word);
        final secondaryMeaning = _uiSecondaryMeaning(context, word);

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _deckChip(word.deck),
                        if (_isTodayRecommendation(word))
                          _statusChip(_todayPickLabel(context), AppColors.gold),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: onBookmark,
                    icon: Icon(
                      word.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SpeakableWordHeadline(
                text: _headline(word),
                fontSize: layout.isCompact ? 23 : 27,
                onTap: onSpeakWord,
              ),
              const SizedBox(height: 8),
              Text(
                secondaryMeaning.trim().isEmpty
                    ? primaryMeaning
                    : '$primaryMeaning  |  $secondaryMeaning',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _pronunciationLine(context, word),
                style: const TextStyle(
                  color: Color(0xFF617180),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SpeechActionButton(
                    icon: Icons.volume_up_rounded,
                    label: _wordAudioLabel(context),
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: _exampleAudioLabel(context),
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: _pronunciationCoachLabel(context),
                    onPressed: onOpenCoach,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                word.exampleSentence,
                style: TextStyle(
                  fontSize: layout.isCompact ? 14 : 15,
                  height: 1.5,
                  color: AppColors.ink,
                ),
                maxLines: layout.isCompact ? 3 : null,
                overflow: layout.isCompact ? TextOverflow.ellipsis : null,
              ),
              const SizedBox(height: 6),
              Text(
                word.exampleTranslation,
                style: TextStyle(
                  fontSize: layout.isCompact ? 13 : 14,
                  height: 1.5,
                  color: const Color(0xFF677785),
                ),
                maxLines: layout.isCompact ? 2 : null,
                overflow: layout.isCompact ? TextOverflow.ellipsis : null,
              ),
              if (_grammarNote(word).isNotEmpty) ...[
                const SizedBox(height: 12),
                _GrammarNotePanel(
                  title: _tr(context, '형태 변화와 문법', 'Forms and grammar'),
                  note: _grammarNote(word),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DeckProgressTile extends StatelessWidget {
  const _DeckProgressTile({required this.summary});

  final _DeckSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: summary.color.withValues(alpha: 0.14),
                child: Icon(Icons.folder_copy_rounded, color: summary.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                _tr(context, '${summary.total}개', '${summary.total} items'),
                style: const TextStyle(
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: summary.ratio,
              backgroundColor: summary.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(summary.color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tr(
              context,
              '숙련도 ${(summary.ratio * 100).round()}%  |  북마크 ${summary.bookmarks}개',
              'Mastery ${(summary.ratio * 100).round()}%  |  Bookmarks ${summary.bookmarks}',
            ),
            style: const TextStyle(
              color: Color(0xFF60707F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionWordTile extends StatelessWidget {
  const _CollectionWordTile({
    required this.word,
    required this.primaryMeaning,
    required this.secondaryMeaning,
    required this.onBookmark,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
  });

  final VocabWord word;
  final String primaryMeaning;
  final String secondaryMeaning;
  final VoidCallback onBookmark;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;
  final Future<void> Function() onOpenCoach;

  @override
  Widget build(BuildContext context) {
    final masteryColor = word.mastery >= 4
        ? AppColors.teal
        : word.mastery >= 2
        ? AppColors.gold
        : AppColors.coral;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _deckChip(word.deck),
                        if (_isTodayRecommendation(word))
                          _statusChip(_todayPickLabel(context), AppColors.gold),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      word.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: word.isBookmarked
                          ? AppColors.coral
                          : AppColors.ink,
                    ),
                  ),
                ],
              ),
              _SpeakableWordHeadline(
                text: _headline(word),
                fontSize: layout.isCompact ? 22 : 24,
                onTap: onSpeakWord,
              ),
              const SizedBox(height: 6),
              Text(
                word.partOfSpeech,
                style: const TextStyle(
                  color: Color(0xFF6A7987),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                secondaryMeaning.trim().isEmpty
                    ? primaryMeaning
                    : '$primaryMeaning  |  $secondaryMeaning',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF455A6E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _voiceLocaleLine(context, word),
                style: const TextStyle(
                  color: Color(0xFF617180),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SpeechActionButton(
                    icon: Icons.volume_up_rounded,
                    label: _wordAudioLabel(context),
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: _exampleAudioLabel(context),
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: _pronunciationCoachLabel(context),
                    onPressed: onOpenCoach,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                word.exampleSentence,
                style: TextStyle(
                  fontSize: layout.isCompact ? 14 : 15,
                  height: 1.5,
                  color: AppColors.ink,
                ),
                maxLines: layout.isCompact ? 3 : null,
                overflow: layout.isCompact ? TextOverflow.ellipsis : null,
              ),
              const SizedBox(height: 6),
              Text(
                word.exampleTranslation,
                style: TextStyle(
                  fontSize: layout.isCompact ? 13 : 14,
                  height: 1.5,
                  color: const Color(0xFF60707F),
                ),
                maxLines: layout.isCompact ? 2 : null,
                overflow: layout.isCompact ? TextOverflow.ellipsis : null,
              ),
              if (_grammarNote(word).isNotEmpty) ...[
                const SizedBox(height: 12),
                _GrammarNotePanel(
                  title: _tr(context, '형태 변화와 문법', 'Forms and grammar'),
                  note: _grammarNote(word),
                  color: AppColors.gold,
                ),
              ],
              const SizedBox(height: 14),
              if (layout.maxWidth < 420)
                Wrap(
                  runSpacing: 10,
                  spacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MasteryPill(
                      masteryColor: masteryColor,
                      mastery: word.mastery,
                    ),
                    Text(
                      _reviewLabel(context, word.nextReviewAt),
                      style: const TextStyle(
                        color: Color(0xFF617180),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    _MasteryPill(
                      masteryColor: masteryColor,
                      mastery: word.mastery,
                    ),
                    const Spacer(),
                    Text(
                      _reviewLabel(context, word.nextReviewAt),
                      style: const TextStyle(
                        color: Color(0xFF617180),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MasteryPill extends StatelessWidget {
  const _MasteryPill({required this.masteryColor, required this.mastery});

  final Color masteryColor;
  final int mastery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: masteryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _masteryLabel(context, mastery),
        style: TextStyle(color: masteryColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.word,
    required this.revealAnswer,
    required this.onReveal,
    required this.onForgot,
    required this.onRemembered,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onOpenCoach,
  });

  final VocabWord word;
  final bool revealAnswer;
  final VoidCallback onReveal;
  final Future<void> Function() onForgot;
  final Future<void> Function() onRemembered;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;
  final Future<void> Function() onOpenCoach;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final primaryMeaning = _uiPrimaryMeaning(context, word);
        final secondaryMeaning = _uiSecondaryMeaning(context, word);
        final detailLines = <String>[
          if (secondaryMeaning.trim().isNotEmpty) secondaryMeaning,
          word.exampleSentence,
          word.exampleTranslation,
        ];

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _deckChip(word.deck),
                        if (_isTodayRecommendation(word))
                          _statusChip(_todayPickLabel(context), AppColors.gold),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _reviewCountLabel(context, word.timesReviewed),
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SpeakableWordHeadline(
                text: _headline(word),
                fontSize: layout.isCompact ? 28 : 34,
                lineHeight: 1.1,
                onTap: onSpeakWord,
              ),
              const SizedBox(height: 12),
              Text(
                _pronunciationMemoLine(context, word),
                style: const TextStyle(
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SpeechActionButton(
                    icon: Icons.volume_up_rounded,
                    label: _wordAudioLabel(context),
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: _exampleAudioLabel(context),
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: _pronunciationCoachLabel(context),
                    onPressed: onOpenCoach,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: revealAnswer
                      ? AppColors.mist.withValues(alpha: 0.75)
                      : AppColors.background.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      revealAnswer
                          ? primaryMeaning
                          : _tr(
                              context,
                              '먼저 뜻을 떠올려 보세요.',
                              'Try to recall the meaning first.',
                            ),
                      style: TextStyle(
                        fontSize: layout.isCompact ? 20 : 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      revealAnswer
                          ? detailLines.join('\n')
                          : _tr(
                              context,
                              '뜻을 확인하기 전에는 예문과 해석이 가려집니다.',
                              'Example lines stay hidden until you reveal the answer.',
                            ),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF566978),
                      ),
                    ),
                  ],
                ),
              ),
              if (revealAnswer && _grammarNote(word).isNotEmpty) ...[
                const SizedBox(height: 14),
                _GrammarNotePanel(
                  title: _tr(context, '형태 변화와 문법', 'Forms and grammar'),
                  note: _grammarNote(word),
                  color: AppColors.gold,
                ),
              ],
              const SizedBox(height: 18),
              if (!revealAnswer)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onReveal,
                    icon: const Icon(Icons.visibility_rounded),
                    label: Text(_tr(context, '뜻 보기', 'Reveal answer')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                )
              else if (layout.maxWidth < 440)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onForgot,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_tr(context, '다시 보기', 'Review again')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: AppColors.coral),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onRemembered,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(_tr(context, '기억했어요', 'I remembered it')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onForgot,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_tr(context, '다시 보기', 'Review again')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: AppColors.coral),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onRemembered,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(_tr(context, '기억했어요', 'I remembered it')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.word});

  final VocabWord word;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final primaryMeaning = _uiPrimaryMeaning(context, word);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.ink.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _headline(word),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      primaryMeaning,
                      style: const TextStyle(color: Color(0xFF617180)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _masteryLabel(context, word.mastery),
                      style: const TextStyle(
                        color: Color(0xFF617180),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.ink.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _headline(word),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            primaryMeaning,
                            style: const TextStyle(color: Color(0xFF617180)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _masteryLabel(context, word.mastery),
                      style: const TextStyle(
                        color: Color(0xFF617180),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SpeechActionButton extends StatelessWidget {
  const _SpeechActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: BorderSide(color: AppColors.ink.withValues(alpha: 0.12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _SpeakableWordHeadline extends StatelessWidget {
  const _SpeakableWordHeadline({
    required this.text,
    required this.fontSize,
    required this.onTap,
    this.lineHeight,
  });

  final String text;
  final double fontSize;
  final double? lineHeight;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _tr(context, '$text 듣기', 'Play $text'),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: lineHeight,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.days});

  final List<_DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final maxReviews = math.max(
      1,
      days.fold<int>(0, (sum, day) => math.max(sum, day.reviews)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final barHeight = isCompact ? 120.0 : 140.0;
        final barWidth = isCompact ? 22.0 : 26.0;
        final chartWidth = math.max(constraints.maxWidth, days.length * 56.0);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: Row(
                children: days.map((day) {
                  final ratio = day.reviews / maxReviews;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Text(
                            '${day.reviews}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: barHeight,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                width: barWidth,
                                height: math.max(18, ratio * (barHeight - 20)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.teal, AppColors.ink],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            day.label,
                            style: const TextStyle(
                              color: Color(0xFF60707F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tr(
                              context,
                              '${day.minutes}분',
                              '${day.minutes} min',
                            ),
                            style: const TextStyle(
                              color: Color(0xFF60707F),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _deckChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.ink.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
    ),
  );
}

Widget _statusChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    ),
  );
}

String _headline(VocabWord word) {
  final article = word.article?.trim();
  if (article == null || article.isEmpty) {
    return word.german;
  }
  return '$article ${word.german}';
}

String _grammarNote(VocabWord word) {
  return word.grammarNote?.trim() ?? '';
}

bool _isTodayRecommendation(VocabWord word) {
  return word.isDailyRecommendation &&
      word.dailyRecommendationDateKey ==
          dailyRecommendationDateKey(DateTime.now());
}

String _reviewLabel(BuildContext context, int? timestamp) {
  if (timestamp == null) {
    return _tr(context, '지금 복습', 'Review now');
  }

  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  if (!date.isAfter(now)) {
    return _tr(context, '지금 복습', 'Review now');
  }
  final diff = date.difference(now);
  if (diff.inHours < 1) {
    return _tr(context, '${diff.inMinutes}분 후', 'In ${diff.inMinutes} min');
  }
  if (diff.inHours < 24) {
    return _tr(context, '${diff.inHours}시간 후', 'In ${diff.inHours} hr');
  }
  return _tr(context, '${diff.inDays}일 후', 'In ${diff.inDays} days');
}

String _voiceLocaleCodeForWord(VocabWord word) {
  return voiceLocaleForLanguageCode(
    languageCode: word.languageCode,
    requestedLocale: word.ttsLocale,
  );
}

String _wordVoiceLocaleLabel(VocabWord word) {
  return voiceLocaleFromCode(_voiceLocaleCodeForWord(word)).displayLabel;
}
