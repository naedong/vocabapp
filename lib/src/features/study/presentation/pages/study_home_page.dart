import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/responsive_layout.dart';
import '../../../../core/audio/pronunciation_assessment_service.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/audio/voice_locale.dart';
import '../../../../core/database/app_database.dart';
import '../../../dictionary/application/dictionary_repository.dart';
import '../../../immersion/application/immersion_repository.dart';
import '../../../immersion/application/news_feed_repository.dart';
import '../../../immersion/data/learning_resource_catalog.dart';
import '../../../immersion/presentation/pages/immersion_hub_page.dart';
import '../../application/study_repository.dart';
import '../../application/study_coach_service.dart';
import '../widgets/add_word_sheet.dart';
import '../widgets/word_coach_sheet.dart';

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
  });

  final StudyRepository repository;
  final DictionaryRepository dictionaryRepository;
  final ImmersionRepository immersionRepository;
  final NewsFeedRepository newsFeedRepository;
  final PronunciationService pronunciationService;
  final PronunciationAssessmentService pronunciationAssessmentService;
  final StudyCoachService studyCoachService;

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  String _selectedDeck = '전체';
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
        final words = List<VocabWord>.from(snapshot.data ?? const <VocabWord>[])
          ..sort(_sortWords);
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
      'Word Collection',
      'Review Session',
      'Real-world German',
      'Study Insights',
    ];
    final subtitles = [
      '독일어 단어 수집, 복습, 통계를 한 흐름으로 묶은 학습 대시보드입니다.',
      '덱과 검색으로 단어를 정리하고, 북마크 카드만 따로 골라볼 수 있습니다.',
      '현재 복습 대기 중인 단어는 ${dueWords.length}개입니다.',
      '뉴스, 영상, 문법 콘텐츠를 보며 실제 독일어가 쓰이는 맥락을 함께 익혀보세요.',
      '최근 학습량과 덱별 숙련도를 보며 다음 루틴을 정리해 보세요.',
    ];
    final useRail = layout.isExpanded;
    final mainPage = _buildPage(
      words: words,
      dueWords: dueWords,
      todayRecommendedWords: todayRecommendedWords,
    );
    final mainContent = _ContentCard(
      title: titles[_selectedIndex],
      subtitle: subtitles[_selectedIndex],
      badge: _badgeLabel(wordCount: words.length, dueCount: dueWords.length),
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
              label: const Text('단어 추가'),
            ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: '홈',
                ),
                NavigationDestination(
                  icon: Icon(Icons.layers_outlined),
                  selectedIcon: Icon(Icons.layers_rounded),
                  label: '컬렉션',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt_rounded),
                  label: '복습',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: '실전',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: '통계',
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
        );
      case 1:
        final allDecks = <String>{
          '전체',
          ...words.map((word) => word.deck),
        }.toList()..sort((a, b) => a == '전체' ? -1 : a.compareTo(b));
        final query = _searchController.text.trim().toLowerCase();
        final filtered = words.where((word) {
          final matchesDeck =
              _selectedDeck == '전체' || _selectedDeck == word.deck;
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
            if (_searchController.text.isEmpty && _selectedDeck == '전체') {
              return;
            }
            setState(() {
              _searchController.clear();
              _selectedDeck = '전체';
            });
          },
          onBookmarkToggle: widget.repository.toggleBookmark,
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
          onOpenCoach: _openWordCoach,
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
            setState(() => _revealAnswer = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  remembered
                      ? '${word.german}를 다음 간격으로 넘겼어요.'
                      : '${word.german}를 가까운 복습 큐에 다시 넣었어요.',
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
        ),
      ),
    );
  }

  Future<void> _openDailyRecommendationSheet() {
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
          defaultDeck: '오늘의 추천',
          initialIsDailyRecommendation: true,
          title: '오늘의 추천 단어 추가',
          subtitle:
              '오늘 꼭 기억하고 싶은 단어를 사전 자동 채움과 함께 저장하면 홈 대시보드의 추천 영역에 바로 나타납니다.',
          submitLabel: '오늘 추천 저장',
        ),
      ),
    );
  }

  Future<void> _speakWord(VocabWord word) async {
    await _speakText(
      word.german,
      locale: word.ttsLocale,
      errorMessage: '단어 발음을 재생하지 못했습니다.',
    );
  }

  Future<void> _speakExample(VocabWord word) async {
    await _speakText(
      word.exampleSentence,
      locale: word.ttsLocale,
      errorMessage: '예문 발음을 재생하지 못했습니다.',
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
        return '오늘 복습 $dueCount개';
      case 3:
        return '실전 자료 ${immersionLearningResources.length}개';
      default:
        return '전체 단어 $wordCount개';
    }
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
    final modules = [
      _DashboardModule(
        tabIndex: 1,
        icon: Icons.layers_rounded,
        label: '컬렉션',
        value: '${words.length}장',
        title: '단어 라이브러리',
        body: '덱과 검색으로 카드를 정리하고 다시 찾을 수 있어요.',
        color: AppColors.teal,
      ),
      _DashboardModule(
        tabIndex: 2,
        icon: Icons.bolt_rounded,
        label: '복습',
        value: '${dueWords.length}개',
        title: '리뷰 세션',
        body: '지금 다시 볼 카드부터 빠르게 이어서 복습합니다.',
        color: AppColors.coral,
      ),
      _DashboardModule(
        tabIndex: 3,
        icon: Icons.explore_rounded,
        label: '실전',
        value: '${immersionLearningResources.length}개',
        title: '실전 독일어',
        body: '뉴스와 자료를 눌러 실제 문맥 속 단어와 바로 연결됩니다.',
        color: AppColors.ink,
      ),
      _DashboardModule(
        tabIndex: 4,
        icon: Icons.insights_rounded,
        label: '통계',
        value: '$average%',
        title: '학습 인사이트',
        body: '리듬과 약한 덱을 확인하며 다음 루틴을 정리할 수 있어요.',
        color: AppColors.gold,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        if (showHero) ...[
          const _HeroBanner(
            color: AppColors.ink,
            eyebrow: 'Study rhythm',
            title: 'Guten Tag.\n오늘의 독일어 흐름을 이어가 보세요.',
            body:
                '웹과 앱에서 같은 Drift 로컬 데이터베이스 흐름으로 단어를 쌓고, 복습 큐를 이어서 관리할 수 있게 구성했습니다.',
          ),
          const SizedBox(height: 20),
        ],
        const _SectionTitle(
          title: '빠른 이동',
          subtitle: '필요한 흐름을 누르면 해당 정보 화면으로 바로 이어집니다.',
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
        const SizedBox(height: 24),
        _AdaptiveCardGrid(
          minTileWidth: 160,
          maxColumns: 4,
          children: [
            _MetricTile(
              label: '전체 단어',
              value: '${words.length}',
              hint: '수집한 카드',
              color: AppColors.ink,
            ),
            _MetricTile(
              label: '오늘 복습',
              value: '${dueWords.length}',
              hint: '지금 다시 볼 카드',
              color: AppColors.coral,
            ),
            _MetricTile(
              label: '오늘 추천',
              value: '${todayRecommendedWords.length}',
              hint: '직접 고른 단어',
              color: AppColors.gold,
            ),
            _MetricTile(
              label: '북마크',
              value: '$bookmarks',
              hint: '집중 카드',
              color: AppColors.teal,
            ),
            _MetricTile(
              label: '숙련도',
              value: '$average%',
              hint: '평균 진행률',
              color: AppColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _SectionTitle(
          title: '오늘의 추천 단어',
          subtitle: '매일 직접 고른 단어를 따로 모아 두고, 단어 뜻과 문법 포인트를 함께 복습해 보세요.',
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAddDailyWord,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('오늘 추천 단어 추가'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (todayRecommendedWords.isEmpty)
          const _EmptyPanel(
            title: '아직 오늘 추천 단어가 없어요.',
            message: '오늘 꼭 기억하고 싶은 단어를 하나 골라 추가해 두면 홈에서 바로 다시 볼 수 있습니다.',
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
        const _SectionTitle(
          title: '오늘의 포커스',
          subtitle: '지금 꺼내 보면 좋은 단어부터 먼저 정리했습니다.',
        ),
        const SizedBox(height: 14),
        if (dueWords.isEmpty)
          const _EmptyPanel(
            title: '오늘 복습 큐가 비어 있어요.',
            message: '새 단어를 추가하거나 컬렉션에서 북마크 카드를 더 쌓아보세요.',
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
        const _SectionTitle(
          title: '덱 스냅샷',
          subtitle: '주제별 진행률을 빠르게 훑어보고 약한 덱을 골라 복습할 수 있습니다.',
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

  @override
  Widget build(BuildContext context) {
    final showHero = MediaQuery.sizeOf(context).width >= 720;
    final hasSearchText = searchController.text.trim().isNotEmpty;
    final hasActiveFilters = hasSearchText || selectedDeck != '전체';

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        if (showHero) ...[
          const _HeroBanner(
            color: AppColors.teal,
            eyebrow: 'Word library',
            title: '단어 컬렉션을 덱별로\n차분하게 쌓아보세요.',
            body: '검색과 덱 필터로 원하는 주제를 빠르게 찾고, 중요한 카드는 북마크로 다시 복습 큐에 불러올 수 있습니다.',
          ),
          const SizedBox(height: 20),
        ],
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: '독일어, 한국어 뜻, 영어 뜻으로 검색',
            suffixIcon: hasSearchText
                ? IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: '검색어 지우기',
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
              label: const Text('검색과 덱 초기화'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (words.isEmpty)
          const _EmptyPanel(
            title: '조건에 맞는 단어가 없어요.',
            message: '검색어를 바꾸거나 다른 덱을 선택해 보세요.',
          )
        else
          ...words.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CollectionWordTile(
                word: word,
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
          if (showHero) ...const [
            _HeroBanner(
              color: AppColors.gold,
              eyebrow: 'Review queue',
              title: '오늘 복습 큐를\n깨끗하게 비웠습니다.',
              body: '새 단어를 추가하면 즉시 복습 큐에 들어가도록 구성해 두었습니다.',
            ),
            SizedBox(height: 20),
          ],
          _EmptyPanel(
            title: '지금은 복습할 카드가 없어요.',
            message: '조금 있다가 다시 오거나 새 단어를 넣어 다음 세션을 시작해 보세요.',
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
            title: '답을 보기 전에 먼저\n뜻과 장면을 떠올려 보세요.',
            body:
                '기억 여부에 따라 복습 간격을 자동으로 다시 배치합니다. 남은 복습은 ${dueWords.length}개입니다.',
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
        const _SectionTitle(title: '다음 카드', subtitle: '곧 이어서 복습하게 될 단어들입니다.'),
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
        final activity = _weeklyActivity(sessions);
        final reviews = activity.fold<int>(0, (sum, day) => sum + day.reviews);
        final minutes = activity.fold<int>(0, (sum, day) => sum + day.minutes);
        final mastered = words.where((word) => word.mastery >= 4).length;
        final weakestDeck = (_deckSummaries(
          words,
        )..sort((a, b) => a.ratio.compareTo(b.ratio))).take(3).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
          children: [
            if (showHero) ...const [
              _HeroBanner(
                color: AppColors.gold,
                eyebrow: 'Learning pulse',
                title: '조용하지만 분명하게,\n학습 리듬을 숫자로 확인하세요.',
                body: '최근 7일 학습량과 덱별 숙련도를 함께 보며 무엇을 더 끌어올려야 할지 빠르게 판단할 수 있습니다.',
              ),
              SizedBox(height: 20),
            ],
            _AdaptiveCardGrid(
              minTileWidth: 170,
              maxColumns: 4,
              children: [
                _MetricTile(
                  label: '이번 주 복습',
                  value: '$reviews',
                  hint: '최근 7일 리뷰 수',
                  color: AppColors.ink,
                ),
                _MetricTile(
                  label: '학습 시간',
                  value: '$minutes분',
                  hint: '최근 7일 누적',
                  color: AppColors.teal,
                ),
                _MetricTile(
                  label: '고숙련',
                  value: '$mastered',
                  hint: '숙련도 4 이상',
                  color: AppColors.gold,
                ),
                _MetricTile(
                  label: '연속 학습',
                  value: '${_streak(sessions)}일',
                  hint: '오늘까지 이어진 루틴',
                  color: AppColors.coral,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: '최근 7일 활동',
              subtitle: '복습 수와 학습 시간을 가볍게 비교할 수 있는 주간 뷰입니다.',
            ),
            const SizedBox(height: 14),
            _ActivityChart(days: activity),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: '보강하면 좋은 덱',
              subtitle: '평균 숙련도가 낮은 순서대로 정렬했습니다.',
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
          const ListTile(
            title: Text(
              'Deutsch Flow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            subtitle: Text('Drift + WASM 독일어 학습 루틴'),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              backgroundColor: Colors.transparent,
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home_rounded),
                  label: Text('홈'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.layers_rounded),
                  label: Text('컬렉션'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    label: Text('$dueCount'),
                    isLabelVisible: dueCount > 0,
                    child: const Icon(Icons.bolt_rounded),
                  ),
                  label: const Text('복습'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.explore_rounded),
                  label: Text('실전'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: Text('통계'),
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
            child: const Text(
              '새 단어를 추가하면 즉시 복습 큐에 들어가도록 설정해 두었습니다.',
              style: TextStyle(height: 1.5, color: Color(0xFF5F6F7C)),
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
    required this.child,
  });

  final String title;
  final String subtitle;
  final String badge;
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
                    ...header,
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
    required this.child,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageIntroHeader(title: title, subtitle: subtitle, badge: badge),
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
  });

  final String title;
  final String subtitle;
  final String badge;

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
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: layout.isCompact ? 26 : 30,
                  ),
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
                          '열어서 보기',
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

List<_DayActivity> _weeklyActivity(List<StudySession> sessions) {
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
      _weekday(day.weekday),
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

String _weekday(int weekday) {
  const labels = ['월', '화', '수', '목', '금', '토', '일'];
  return labels[(weekday - 1).clamp(0, 6)];
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
    this.title = '문법 메모',
    this.color = AppColors.teal,
  });

  final String note;
  final String title;
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
            title,
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
                          _statusChip('오늘 추천', AppColors.gold),
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
              Text(
                _headline(word),
                style: TextStyle(
                  fontSize: layout.isCompact ? 23 : 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${word.meaningKo}  |  ${word.meaningEn}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '발음: ${word.pronunciation}  |  음성: ${_voiceLocaleLabel(word.ttsLocale)}',
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
                    label: '단어 듣기',
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: '예문 듣기',
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: '발음 점검',
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
                _GrammarNotePanel(note: _grammarNote(word)),
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
                '${summary.total}개',
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
            '숙련도 ${(summary.ratio * 100).round()}%  |  북마크 ${summary.bookmarks}개',
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
                          _statusChip('오늘 추천', AppColors.gold),
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
              Text(
                _headline(word),
                style: TextStyle(
                  fontSize: layout.isCompact ? 22 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
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
                '${word.meaningKo}  |  ${word.meaningEn}',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF455A6E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '음성 locale: ${_voiceLocaleLabel(word.ttsLocale)}',
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
                    label: '단어 듣기',
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: '예문 듣기',
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: '발음 점검',
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
                      _reviewLabel(word.nextReviewAt),
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
                      _reviewLabel(word.nextReviewAt),
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
        '숙련도 $mastery/5',
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
                          _statusChip('오늘 추천', AppColors.gold),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '리뷰 ${word.timesReviewed}회',
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _headline(word),
                style: TextStyle(
                  fontSize: layout.isCompact ? 28 : 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '발음 메모: ${word.pronunciation}\n음성 locale: ${_voiceLocaleLabel(word.ttsLocale)}',
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
                    label: '단어 듣기',
                    onPressed: onSpeakWord,
                  ),
                  _SpeechActionButton(
                    icon: Icons.record_voice_over_rounded,
                    label: '예문 듣기',
                    onPressed: onSpeakExample,
                  ),
                  _SpeechActionButton(
                    icon: Icons.mic_external_on_rounded,
                    label: '발음 점검',
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
                      revealAnswer ? word.meaningKo : '먼저 뜻을 떠올려 보세요.',
                      style: TextStyle(
                        fontSize: layout.isCompact ? 20 : 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      revealAnswer
                          ? '${word.meaningEn}\n${word.exampleSentence}\n${word.exampleTranslation}'
                          : '뜻을 확인하기 전에는 예문과 해석이 가려집니다.',
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
                  title: '문법 포인트',
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
                    label: const Text('뜻 보기'),
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
                        label: const Text('다시 보기'),
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
                        label: const Text('기억했어요'),
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
                        label: const Text('다시 보기'),
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
                        label: const Text('기억했어요'),
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
                      word.meaningKo,
                      style: const TextStyle(color: Color(0xFF617180)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '숙련도 ${word.mastery}/5',
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
                            word.meaningKo,
                            style: const TextStyle(color: Color(0xFF617180)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '숙련도 ${word.mastery}/5',
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
                            '${day.minutes}분',
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

String _reviewLabel(int? timestamp) {
  if (timestamp == null) {
    return '지금 복습';
  }

  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  if (!date.isAfter(now)) {
    return '지금 복습';
  }
  final diff = date.difference(now);
  if (diff.inHours < 1) {
    return '${diff.inMinutes}분 후';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}시간 후';
  }
  return '${diff.inDays}일 후';
}

String _voiceLocaleLabel(String locale) {
  return voiceLocaleFromCode(locale).displayLabel;
}
