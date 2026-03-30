import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/database/app_database.dart';
import '../../application/study_repository.dart';
import '../widgets/add_word_sheet.dart';

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({
    super.key,
    required this.repository,
    required this.pronunciationService,
  });

  final StudyRepository repository;
  final PronunciationService pronunciationService;

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1080;
            final shell = _buildShell(
              context,
              words: words,
              dueWords: dueWords,
              isWide: isWide,
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
    required bool isWide,
  }) {
    final titles = [
      'Deutsch Flow',
      'Word Collection',
      'Review Session',
      'Study Insights',
    ];
    final subtitles = [
      '독일어 단어 수집, 복습, 통계를 한 흐름으로 묶은 학습 대시보드입니다.',
      '덱과 검색으로 단어를 정리하고, 북마크 카드만 따로 골라볼 수 있습니다.',
      '현재 복습 대기 중인 단어는 ${dueWords.length}개입니다.',
      '최근 학습량과 덱별 숙련도를 보며 다음 루틴을 정리해 보세요.',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddWordSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('단어 추가'),
      ),
      bottomNavigationBar: isWide
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
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: '통계',
                ),
              ],
            ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            0,
          ),
          child: isWide
              ? Row(
                  children: [
                    _RailCard(
                      selectedIndex: _selectedIndex,
                      dueCount: dueWords.length,
                      onSelected: _selectTab,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _ContentCard(
                        title: titles[_selectedIndex],
                        subtitle: subtitles[_selectedIndex],
                        badge: _selectedIndex == 2
                            ? '오늘 복습 ${dueWords.length}개'
                            : '전체 단어 ${words.length}개',
                        child: _buildPage(words: words, dueWords: dueWords),
                      ),
                    ),
                  ],
                )
              : _ContentCard(
                  title: titles[_selectedIndex],
                  subtitle: subtitles[_selectedIndex],
                  badge: _selectedIndex == 2
                      ? '오늘 복습 ${dueWords.length}개'
                      : '전체 단어 ${words.length}개',
                  child: _buildPage(words: words, dueWords: dueWords),
                ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required List<VocabWord> words,
    required List<VocabWord> dueWords,
  }) {
    switch (_selectedIndex) {
      case 0:
        return _DashboardPage(
          words: words,
          dueWords: dueWords,
          onBookmarkToggle: widget.repository.toggleBookmark,
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
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
          onBookmarkToggle: widget.repository.toggleBookmark,
          onSpeakWord: _speakWord,
          onSpeakExample: _speakExample,
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
          repository: widget.repository,
          pronunciationService: widget.pronunciationService,
        ),
      ),
    );
  }

  Future<void> _speakWord(VocabWord word) async {
    await _speakText(word.german, errorMessage: '단어 발음을 재생하지 못했습니다.');
  }

  Future<void> _speakExample(VocabWord word) async {
    await _speakText(word.exampleSentence, errorMessage: '예문 발음을 재생하지 못했습니다.');
  }

  Future<void> _speakText(String text, {required String errorMessage}) async {
    try {
      await widget.pronunciationService.speakGerman(text);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _revealAnswer = false;
      }
    });
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
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.words,
    required this.dueWords,
    required this.onBookmarkToggle,
    required this.onSpeakWord,
    required this.onSpeakExample,
  });

  final List<VocabWord> words;
  final List<VocabWord> dueWords;
  final Future<void> Function(VocabWord word) onBookmarkToggle;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;

  @override
  Widget build(BuildContext context) {
    final deckSummaries = _deckSummaries(words);
    final average = words.isEmpty
        ? 0
        : ((words.fold<int>(0, (sum, word) => sum + word.mastery) /
                      (words.length * 5)) *
                  100)
              .round();
    final bookmarks = words.where((word) => word.isBookmarked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        const _HeroBanner(
          color: AppColors.ink,
          eyebrow: 'Study rhythm',
          title: 'Guten Tag.\n오늘의 독일어 흐름을 이어가 보세요.',
          body:
              '웹과 앱에서 같은 Drift 로컬 데이터베이스 흐름으로 단어를 쌓고, 복습 큐를 이어서 관리할 수 있게 구성했습니다.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
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
    required this.onBookmarkToggle,
    required this.onSpeakWord,
    required this.onSpeakExample,
  });

  final List<VocabWord> words;
  final List<String> decks;
  final String selectedDeck;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDeckSelected;
  final Future<void> Function(VocabWord word) onBookmarkToggle;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      children: [
        const _HeroBanner(
          color: AppColors.teal,
          eyebrow: 'Word library',
          title: '단어 컬렉션을 덱별로\n차분하게 쌓아보세요.',
          body: '검색과 덱 필터로 원하는 주제를 빠르게 찾고, 중요한 카드는 북마크로 다시 복습 큐에 불러올 수 있습니다.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: '독일어, 한국어 뜻, 영어 뜻으로 검색',
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
  });

  final List<VocabWord> dueWords;
  final bool revealAnswer;
  final VoidCallback onReveal;
  final Future<void> Function(VocabWord word, bool remembered) onReview;
  final Future<void> Function(VocabWord word) onSpeakWord;
  final Future<void> Function(VocabWord word) onSpeakExample;

  @override
  Widget build(BuildContext context) {
    if (dueWords.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
        children: const [
          _HeroBanner(
            color: AppColors.gold,
            eyebrow: 'Review queue',
            title: '오늘 복습 큐를\n깨끗하게 비웠습니다.',
            body: '새 단어를 추가하면 즉시 복습 큐에 들어가도록 구성해 두었습니다.',
          ),
          SizedBox(height: 20),
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
        _HeroBanner(
          color: AppColors.coral,
          eyebrow: 'Active recall',
          title: '답을 보기 전에 먼저\n뜻과 장면을 떠올려 보세요.',
          body:
              '기억 여부에 따라 복습 간격을 자동으로 다시 배치합니다. 남은 복습은 ${dueWords.length}개입니다.',
        ),
        const SizedBox(height: 20),
        _PracticeCard(
          word: current,
          revealAnswer: revealAnswer,
          onReveal: onReveal,
          onForgot: () => onReview(current, false),
          onRemembered: () => onReview(current, true),
          onSpeakWord: () => onSpeakWord(current),
          onSpeakExample: () => onSpeakExample(current),
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
            const _HeroBanner(
              color: AppColors.gold,
              eyebrow: 'Learning pulse',
              title: '조용하지만 분명하게,\n학습 리듬을 숫자로 확인하세요.',
              body: '최근 7일 학습량과 덱별 숙련도를 함께 보며 무엇을 더 끌어올려야 할지 빠르게 판단할 수 있습니다.',
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 14,
              runSpacing: 14,
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
  });

  final int selectedIndex;
  final int dueCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(34),
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
        borderRadius: BorderRadius.circular(34),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(child: child),
            ],
          ),
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.08,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
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
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(Icons.auto_awesome_rounded, color: color),
            ),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(color: Color(0xFF617180))),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(hint, style: const TextStyle(color: Color(0xFF617180))),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF617180),
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF617180),
            ),
            textAlign: TextAlign.center,
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
  });

  final VocabWord word;
  final VoidCallback onBookmark;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _deckChip(word.deck),
              const Spacer(),
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
            style: const TextStyle(
              fontSize: 27,
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
            '발음: ${word.pronunciation}',
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            word.exampleSentence,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word.exampleTranslation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF677785),
            ),
          ),
        ],
      ),
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
  });

  final VocabWord word;
  final VoidCallback onBookmark;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;

  @override
  Widget build(BuildContext context) {
    final masteryColor = word.mastery >= 4
        ? AppColors.teal
        : word.mastery >= 2
        ? AppColors.gold
        : AppColors.coral;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _deckChip(word.deck),
              const Spacer(),
              IconButton(
                onPressed: onBookmark,
                icon: Icon(
                  word.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: word.isBookmarked ? AppColors.coral : AppColors.ink,
                ),
              ),
            ],
          ),
          Text(
            _headline(word),
            style: const TextStyle(
              fontSize: 24,
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
            ],
          ),
          const SizedBox(height: 10),
          Text(
            word.exampleSentence,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word.exampleTranslation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF60707F),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: masteryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '숙련도 ${word.mastery}/5',
                  style: TextStyle(
                    color: masteryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
  });

  final VocabWord word;
  final bool revealAnswer;
  final VoidCallback onReveal;
  final Future<void> Function() onForgot;
  final Future<void> Function() onRemembered;
  final Future<void> Function() onSpeakWord;
  final Future<void> Function() onSpeakExample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _deckChip(word.deck),
              const Spacer(),
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
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '발음 메모: ${word.pronunciation}',
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
                  style: const TextStyle(
                    fontSize: 22,
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
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.word});

  final VocabWord word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.ink.withValues(alpha: 0.1),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.ink),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
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
                    height: 140,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: 26,
                        height: math.max(18, ratio * 120),
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

String _headline(VocabWord word) {
  final article = word.article?.trim();
  if (article == null || article.isEmpty) {
    return word.german;
  }
  return '$article ${word.german}';
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
