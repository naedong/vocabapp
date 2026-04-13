import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/responsive_layout.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/config/news_api_config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../dictionary/application/dictionary_repository.dart';
import '../../../study/application/study_repository.dart';
import '../../application/immersion_repository.dart';
import '../../application/news_feed_repository.dart';
import '../../data/learning_resource_catalog.dart';
import '../../domain/learning_resource.dart';
import '../../domain/news_article.dart';
import 'article_reader_page.dart';

class ImmersionHubPage extends StatefulWidget {
  const ImmersionHubPage({
    super.key,
    required this.repository,
    required this.dictionaryRepository,
    required this.studyRepository,
    required this.newsFeedRepository,
    required this.pronunciationService,
    required this.knownWords,
  });

  final ImmersionRepository repository;
  final DictionaryRepository dictionaryRepository;
  final StudyRepository studyRepository;
  final NewsFeedRepository newsFeedRepository;
  final PronunciationService pronunciationService;
  final List<VocabWord> knownWords;

  @override
  State<ImmersionHubPage> createState() => _ImmersionHubPageState();
}

class _ImmersionHubPageState extends State<ImmersionHubPage> {
  static const _defaultCategoryId = 'general';
  static const _categoryPresetQueries = <String, String>{
    'general': 'Deutschland',
    'business': 'Wirtschaft',
    'technology': 'Technologie',
    'science': 'Wissenschaft',
    'health': 'Gesundheit',
    'entertainment': 'Kultur',
    'sports': 'Sport',
  };
  static const _categories = <_NewsCategoryOption>[
    _NewsCategoryOption('all', '전체 추천'),
    _NewsCategoryOption('general', '일반'),
    _NewsCategoryOption('business', '비즈니스'),
    _NewsCategoryOption('technology', '테크'),
    _NewsCategoryOption('science', '과학'),
    _NewsCategoryOption('health', '헬스'),
    _NewsCategoryOption('entertainment', '문화'),
    _NewsCategoryOption('sports', '스포츠'),
  ];
  static const _suggestedQueries = <String>[
    'Deutschland',
    'Berlin',
    'Wirtschaft',
    'Technologie',
    'KI',
  ];

  final TextEditingController _searchController = TextEditingController();

  late Future<List<NewsArticle>> _articlesFuture;
  String _selectedCategory = _defaultCategoryId;

  @override
  void initState() {
    super.initState();
    _applyCategoryPreset(_selectedCategory);
    _articlesFuture = _loadArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showOverview = MediaQuery.sizeOf(context).width >= 720;
    final featuredResources = <LearningResource>[
      ..._byType(LearningResourceType.news).take(2),
      ..._byType(LearningResourceType.video).take(1),
      ..._byType(LearningResourceType.grammar).take(1),
    ];

    return RefreshIndicator(
      onRefresh: _refreshArticles,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
        children: [
          if (showOverview) ...const [
            _ImmersionOverviewCard(),
            SizedBox(height: 20),
          ],
          _LiveNewsPanel(
            searchController: _searchController,
            selectedCategory: _selectedCategory,
            categories: _categories,
            articlesFuture: _articlesFuture,
            onSearchSubmitted: _searchNews,
            onClearSearch: _clearSearch,
            onCategorySelected: _selectCategory,
            onRefreshRequested: _refreshArticles,
            onOpenArticleStudy: _openArticleStudy,
            suggestedQueries: _suggestedQueries,
            onSuggestedQuerySelected: _applySuggestedQuery,
          ),
          if (featuredResources.isNotEmpty) ...[
            const SizedBox(height: 24),
            _ResourceSection(
              title: '추가 학습 자료',
              subtitle: '뉴스 검색만으로 부족할 때 바로 이어서 볼 수 있는 공식 독일어 학습 자료만 남겼습니다.',
              resources: featuredResources,
            ),
          ],
        ],
      ),
    );
  }

  List<LearningResource> _byType(LearningResourceType type) {
    return immersionLearningResources
        .where((resource) => resource.type == type)
        .toList();
  }

  Future<List<NewsArticle>> _loadArticles({bool forceRefresh = false}) {
    final query = _resolvedQuery();
    if (query.isNotEmpty) {
      return widget.newsFeedRepository.searchGermanArticles(
        query,
        forceRefresh: forceRefresh,
      );
    }

    return widget.newsFeedRepository.loadTopHeadlines(
      category: _selectedCategory,
      forceRefresh: forceRefresh,
    );
  }

  String _resolvedQuery() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      return query;
    }
    return _categoryPresetQueries[_selectedCategory] ?? '';
  }

  void _applyCategoryPreset(String category) {
    final preset = _categoryPresetQueries[category];
    if (preset == null) {
      return;
    }
    _searchController.value = TextEditingValue(
      text: preset,
      selection: TextSelection.collapsed(offset: preset.length),
    );
  }

  Future<void> _refreshArticles({bool showLoader = true}) async {
    AppLogger.info(
      'ImmersionHubPage',
      'Refreshing news list.',
      details: <String, Object?>{
        'category': _selectedCategory,
        'query': _searchController.text.trim(),
      },
    );
    final future = _loadArticles(forceRefresh: true);
    if (mounted && showLoader) {
      setState(() => _articlesFuture = future);
    }
    await future;
  }

  void _searchNews() {
    final query = _resolvedQuery();
    if (_searchController.text.trim().isEmpty && query.isNotEmpty) {
      _applyCategoryPreset(_selectedCategory);
    }
    AppLogger.info(
      'ImmersionHubPage',
      'Submitting news search.',
      details: <String, Object?>{'query': query, 'category': _selectedCategory},
    );
    setState(() => _articlesFuture = _loadArticles());
  }

  void _selectCategory(String category) {
    final previousQuery = _searchController.text.trim();
    final presetQuery = _categoryPresetQueries[category];
    if (_selectedCategory == category &&
        (presetQuery == null || previousQuery == presetQuery)) {
      return;
    }

    setState(() {
      _selectedCategory = category;
      _applyCategoryPreset(category);
      _articlesFuture = _loadArticles();
    });
    AppLogger.info(
      'ImmersionHubPage',
      'News category selected.',
      details: <String, Object?>{
        'category': category,
        'previousQuery': previousQuery,
        'appliedPresetQuery': presetQuery,
      },
    );
  }

  Future<void> _openArticleStudy(NewsArticle article) {
    AppLogger.info(
      'ImmersionHubPage',
      'Opening article reader.',
      details: <String, Object?>{'title': article.title, 'url': article.url},
    );
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ArticleReaderPage(
          article: article,
          repository: widget.repository,
          dictionaryRepository: widget.dictionaryRepository,
          studyRepository: widget.studyRepository,
          pronunciationService: widget.pronunciationService,
          knownWords: widget.knownWords,
        ),
      ),
    );
  }

  void _applySuggestedQuery(String query) {
    _searchController.text = query;
    _searchNews();
  }

  void _clearSearch() {
    _applyCategoryPreset(_selectedCategory);
    setState(() => _articlesFuture = _loadArticles());
  }
}

class _ImmersionOverviewCard extends StatelessWidget {
  const _ImmersionOverviewCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(layout.panelRadius),
            gradient: const LinearGradient(
              colors: [AppColors.ink, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PillLabel(label: 'Real-world German'),
              const SizedBox(height: 16),
              Text(
                '실전 독일어 뉴스만\n바로 읽을 수 있게 정리했습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: layout.isCompact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '검색은 버튼을 눌렀을 때만 호출되고, 같은 요청은 캐시를 우선 사용합니다. 기사에 들어가면 불필요한 꼬리 문구를 제거한 뒤 읽기용 본문으로 보여줍니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: layout.bodySize,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveNewsPanel extends StatelessWidget {
  const _LiveNewsPanel({
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.articlesFuture,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onCategorySelected,
    required this.onRefreshRequested,
    required this.onOpenArticleStudy,
    required this.suggestedQueries,
    required this.onSuggestedQuerySelected,
  });

  final TextEditingController searchController;
  final String selectedCategory;
  final List<_NewsCategoryOption> categories;
  final Future<List<NewsArticle>> articlesFuture;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onCategorySelected;
  final Future<void> Function() onRefreshRequested;
  final Future<void> Function(NewsArticle article) onOpenArticleStudy;
  final List<String> suggestedQueries;
  final ValueChanged<String> onSuggestedQuerySelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final controls = [
          const Text(
            '실시간 독일 뉴스',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '같은 요청은 캐시를 먼저 보고, 검색은 버튼을 누르거나 엔터를 칠 때만 실행됩니다.',
            style: TextStyle(height: 1.55, color: Color(0xFF60707F)),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 14),
            const _InfoBanner(
              icon: Icons.shield_outlined,
              message:
                  '웹 빌드에서는 NewsAPI 키가 브라우저에 노출될 수 있습니다. 배포용으로는 서버 프록시를 두는 것을 권장합니다.',
            ),
          ],
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              final hasSearchText = value.text.trim().isNotEmpty;
              return TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearchSubmitted(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: '예: Berlin, Wirtschaft, KI, Energie',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasSearchText)
                        IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          tooltip: '검색어 지우기',
                        ),
                      IconButton(
                        onPressed: onSearchSubmitted,
                        icon: const Icon(Icons.search_rounded),
                        tooltip: '검색',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedQueries.map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () => onSuggestedQuerySelected(query),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category.label),
                selected: category.id == selectedCategory,
                onSelected: (_) => onCategorySelected(category.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onSearchSubmitted,
                icon: const Icon(Icons.travel_explore_rounded),
                label: const Text('검색'),
              ),
              OutlinedButton.icon(
                onPressed: onRefreshRequested,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('새로고침'),
              ),
            ],
          ),
        ];

        final articleSection = !NewsApiConfig.hasKey
            ? const _EmptyPanel(
                title: 'News API 키가 비어 있습니다.',
                message: '로컬 설정 파일이나 dart-define에 키를 넣으면 실시간 뉴스가 표시됩니다.',
              )
            : FutureBuilder<List<NewsArticle>>(
                future: articlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _LoadingPanel();
                  }

                  if (snapshot.hasError) {
                    return _ErrorPanel(
                      message: '${snapshot.error}',
                      onRetry: onRefreshRequested,
                    );
                  }

                  final articles = snapshot.data ?? const <NewsArticle>[];
                  if (articles.isEmpty) {
                    return const _EmptyPanel(
                      title: '조건에 맞는 기사가 없습니다.',
                      message: '검색어를 바꾸거나 카테고리를 다시 선택해 보세요.',
                    );
                  }

                  return Column(
                    children: articles
                        .map(
                          (article) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LiveNewsCard(
                              article: article,
                              onOpenStudy: () => onOpenArticleStudy(article),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              );

        if (layout.isCompact) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(layout.cardPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(layout.panelRadius),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controls,
                ),
              ),
              const SizedBox(height: 16),
              articleSection,
            ],
          );
        }

        return Container(
          padding: EdgeInsets.all(layout.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(layout.panelRadius),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...controls, const SizedBox(height: 18), articleSection],
          ),
        );
      },
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            '독일 뉴스 기사를 불러오는 중입니다.',
            style: TextStyle(
              color: Color(0xFF60707F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '뉴스를 불러오지 못했습니다.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(height: 1.5, color: Color(0xFF5F6F7C)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(height: 1.55, color: Color(0xFF60707F)),
          ),
        ],
      ),
    );
  }
}

class _LiveNewsCard extends StatelessWidget {
  const _LiveNewsCard({required this.article, required this.onOpenStudy});

  final NewsArticle article;
  final Future<void> Function() onOpenStudy;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final compact = layout.isCompact;
        final hasImage =
            article.imageUrl != null && article.imageUrl!.trim().isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: compact
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            article.imageUrl!,
                            width: 92,
                            height: 116,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      if (hasImage) const SizedBox(width: 14),
                      Expanded(
                        child: _ArticleCardContent(
                          article: article,
                          compact: true,
                          onOpenStudy: onOpenStudy,
                          onOpenArticle: () => _openArticle(context),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Image.network(
                          article.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(layout.cardPadding),
                      child: _ArticleCardContent(
                        article: article,
                        compact: false,
                        onOpenStudy: onOpenStudy,
                        onOpenArticle: () => _openArticle(context),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final launched = await launchUrl(
      Uri.parse(article.url),
      mode: LaunchMode.platformDefault,
    );

    if (launched || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('현재 환경에서 기사 링크를 열지 못했습니다.')));
  }
}

class _ArticleCardContent extends StatelessWidget {
  const _ArticleCardContent({
    required this.article,
    required this.compact,
    required this.onOpenStudy,
    required this.onOpenArticle,
  });

  final NewsArticle article;
  final bool compact;
  final Future<void> Function() onOpenStudy;
  final VoidCallback onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                article.sourceName,
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 12 : 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _publishedLabel(article.publishedAt),
              style: TextStyle(
                color: const Color(0xFF60707F),
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          article.title,
          style: TextStyle(
            fontSize: compact ? 16 : 21,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            height: 1.28,
          ),
          maxLines: compact ? 3 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
        ),
        const SizedBox(height: 8),
        Text(
          article.description,
          style: TextStyle(
            height: 1.5,
            color: const Color(0xFF4C6074),
            fontSize: compact ? 13 : 14,
          ),
          maxLines: compact ? 4 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onOpenStudy,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(compact ? '학습' : '읽으며 공부'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 14 : 18,
                  vertical: compact ? 12 : 16,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onOpenArticle,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('원문 열기'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                height: 1.5,
                color: Color(0xFF5F6F7C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceSection extends StatelessWidget {
  const _ResourceSection({
    required this.title,
    required this.subtitle,
    required this.resources,
  });

  final String title;
  final String subtitle;
  final List<LearningResource> resources;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF60707F), height: 1.5),
        ),
        const SizedBox(height: 14),
        ...resources.map(
          (resource) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ResourceCard(resource: resource),
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final LearningResource resource;

  @override
  Widget build(BuildContext context) {
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
              _TypeBadge(type: resource.type),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resource.source,
                  style: const TextStyle(
                    color: Color(0xFF60707F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                resource.level,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            resource.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resource.description,
            style: const TextStyle(height: 1.55, color: Color(0xFF4C6074)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '학습 활용법: ${resource.useCase}',
              style: const TextStyle(
                height: 1.55,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(label: resource.format),
              ...resource.tags.map((tag) => _TagChip(label: tag)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openResource(context),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('콘텐츠 열기'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openResource(BuildContext context) async {
    final uri = Uri.parse(resource.url);
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (launched || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('현재 환경에서 링크를 열지 못했습니다.')));
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final LearningResourceType type;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String label;

    switch (type) {
      case LearningResourceType.news:
        icon = Icons.newspaper_rounded;
        color = AppColors.coral;
        label = '뉴스';
      case LearningResourceType.video:
        icon = Icons.play_circle_rounded;
        color = AppColors.teal;
        label = '영상';
      case LearningResourceType.grammar:
        icon = Icons.rule_rounded;
        color = AppColors.gold;
        label = '문법';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NewsCategoryOption {
  const _NewsCategoryOption(this.id, this.label);

  final String id;
  final String label;
}

String _publishedLabel(DateTime? publishedAt) {
  if (publishedAt == null) {
    return '방금';
  }

  final local = publishedAt.toLocal();
  return '${local.month}/${local.day} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
