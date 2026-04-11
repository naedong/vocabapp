import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/responsive_layout.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../dictionary/application/dictionary_repository.dart';
import '../../../dictionary/domain/dictionary_lookup.dart';
import '../../application/immersion_repository.dart';
import '../../application/reading_word_suggester.dart';
import '../../application/script_analyzer.dart';
import '../../domain/news_article.dart';
import '../../../study/application/study_repository.dart';
import '../../../study/presentation/widgets/add_word_sheet.dart';

class ArticleReaderPage extends StatefulWidget {
  const ArticleReaderPage({
    super.key,
    required this.article,
    required this.repository,
    required this.dictionaryRepository,
    required this.studyRepository,
    required this.pronunciationService,
    required this.knownWords,
  });

  final NewsArticle article;
  final ImmersionRepository repository;
  final DictionaryRepository dictionaryRepository;
  final StudyRepository studyRepository;
  final PronunciationService pronunciationService;
  final List<VocabWord> knownWords;

  @override
  State<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends State<ArticleReaderPage> {
  late Future<ReadingDocument> _documentFuture;
  bool _isSourceSyncing = false;
  bool _hasAttemptedAutoSourceSync = false;
  String? _sourceSyncMessage;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'ArticleReaderPage',
      'Opening article reader.',
      details: <String, Object?>{
        'title': widget.article.title,
        'url': widget.article.url,
        'requiresSourceEnrichment': widget.article.requiresSourceEnrichment,
      },
    );
    _documentFuture = widget.repository.prepareDocument(widget.article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('기사 읽기 학습'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<ReadingDocument>(
        future: _documentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ReaderStatePanel(
              title: '학습 문서를 열지 못했습니다.',
              message: '${snapshot.error ?? '알 수 없는 오류'}',
            );
          }

          final document = snapshot.data!;
          if (!_hasAttemptedAutoSourceSync) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _maybeSyncSource(document);
              }
            });
          }
          return _ReaderLoadedView(
            article: widget.article,
            document: document,
            repository: widget.repository,
            dictionaryRepository: widget.dictionaryRepository,
            studyRepository: widget.studyRepository,
            pronunciationService: widget.pronunciationService,
            knownWords: widget.knownWords,
            onScriptUpdated: _reloadDocument,
            isSourceSyncing: _isSourceSyncing,
            sourceSyncMessage: _sourceSyncMessage,
            onRefreshFromSource: () => _syncSource(document, automatic: false),
          );
        },
      ),
    );
  }

  Future<void> _reloadDocument() async {
    final future = widget.repository.prepareDocument(widget.article);
    if (mounted) {
      setState(() => _documentFuture = future);
    }
    await future;
  }

  Future<void> _maybeSyncSource(ReadingDocument document) async {
    _hasAttemptedAutoSourceSync = true;
    if (!widget.article.requiresSourceEnrichment) {
      return;
    }

    final currentLength = document.scriptText.trim().length;
    if (currentLength >= 1400) {
      AppLogger.info(
        'ArticleReaderPage',
        'Skipping auto source sync because the current script is already long enough.',
        details: <String, Object?>{
          'documentId': document.id,
          'length': currentLength,
        },
      );
      return;
    }

    await _syncSource(document, automatic: true);
  }

  Future<void> _syncSource(
    ReadingDocument document, {
    required bool automatic,
  }) async {
    if (_isSourceSyncing) {
      return;
    }

    setState(() {
      _isSourceSyncing = true;
      _sourceSyncMessage = automatic
          ? '원문 본문을 확인하는 중입니다.'
          : '원문 본문을 다시 확인하는 중입니다.';
    });

    final result = await widget.repository.enrichDocumentFromSource(
      article: widget.article,
      document: document,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSourceSyncing = false;
      _sourceSyncMessage = result.message;
      _documentFuture = Future.value(result.document);
    });
  }
}

class _ReaderLoadedView extends StatefulWidget {
  const _ReaderLoadedView({
    required this.article,
    required this.document,
    required this.repository,
    required this.dictionaryRepository,
    required this.studyRepository,
    required this.pronunciationService,
    required this.knownWords,
    required this.onScriptUpdated,
    required this.isSourceSyncing,
    required this.sourceSyncMessage,
    required this.onRefreshFromSource,
  });

  final NewsArticle article;
  final ReadingDocument document;
  final ImmersionRepository repository;
  final DictionaryRepository dictionaryRepository;
  final StudyRepository studyRepository;
  final PronunciationService pronunciationService;
  final List<VocabWord> knownWords;
  final Future<void> Function() onScriptUpdated;
  final bool isSourceSyncing;
  final String? sourceSyncMessage;
  final Future<void> Function() onRefreshFromSource;

  @override
  State<_ReaderLoadedView> createState() => _ReaderLoadedViewState();
}

class _ReaderLoadedViewState extends State<_ReaderLoadedView> {
  _SelectedWord? _selectedWord;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReadingNote>>(
      stream: widget.repository.watchWordNotes(widget.document.id),
      builder: (context, wordSnapshot) {
        final wordNotes = wordSnapshot.data ?? const <ReadingNote>[];
        return StreamBuilder<List<ReadingNote>>(
          stream: widget.repository.watchGrammarNotes(widget.document.id),
          builder: (context, grammarSnapshot) {
            final grammarNotes = grammarSnapshot.data ?? const <ReadingNote>[];
            final knownWordIndex = _indexKnownWords(widget.knownWords);
            final wordNoteIndex = {
              for (final note in wordNotes)
                (note.normalizedText?.toLowerCase() ??
                        note.surfaceText.toLowerCase()):
                    note,
            };
            final grammarNoteIndex = {
              for (final note in grammarNotes)
                (note.normalizedText?.toLowerCase() ??
                        note.surfaceText.toLowerCase()):
                    note,
            };
            final paragraphs = ScriptAnalyzer.tokenizeParagraphs(
              widget.document.scriptText,
            );
            final grammarInsights = ScriptAnalyzer.detectGrammarInsights(
              widget.document.scriptText,
            );
            final selectedNormalized = _selectedWord?.token.normalized
                .toLowerCase();
            final selectedKnownMatches = selectedNormalized == null
                ? const <VocabWord>[]
                : knownWordIndex[selectedNormalized] ?? const <VocabWord>[];
            final selectedSavedNote = selectedNormalized == null
                ? null
                : wordNoteIndex[selectedNormalized];
            final selectedSuggestion = _selectedWord == null
                ? null
                : ReadingWordSuggester.suggest(
                    token: _selectedWord!.token,
                    knownMatches: selectedKnownMatches,
                  );
            final selectedRelatedInsights = _selectedWord == null
                ? const <GrammarInsight>[]
                : _relatedInsights(
                    token: _selectedWord!.token,
                    sentenceSnippet: _selectedWord!.contextSnippet,
                    allInsights: grammarInsights,
                  );
            final layout = ResponsiveLayout.fromWidth(
              MediaQuery.sizeOf(context).width,
            );

            return ListView(
              padding: EdgeInsets.fromLTRB(
                layout.isCompact ? 12 : 16,
                8,
                layout.isCompact ? 12 : 16,
                32,
              ),
              children: [
                _ArticleHeroCard(
                  article: widget.article,
                  wordNoteCount: wordNotes.length,
                  grammarNoteCount: grammarNotes.length,
                  onEditScript: () => _openScriptEditor(context),
                  onSpeakTitle: () => widget.pronunciationService.speak(
                    widget.article.title,
                    locale: 'de-DE',
                  ),
                  onRefreshFromSource: widget.onRefreshFromSource,
                  isSourceSyncing: widget.isSourceSyncing,
                  sourceSyncMessage: widget.sourceSyncMessage,
                ),
                const SizedBox(height: 18),
                if (widget.article.requiresSourceEnrichment ||
                    widget.sourceSyncMessage != null)
                  _InlineInfoCard(
                    icon: widget.isSourceSyncing
                        ? Icons.sync_rounded
                        : Icons.info_outline_rounded,
                    title: widget.isSourceSyncing
                        ? '원문 본문을 확인하고 있습니다.'
                        : '본문 상태',
                    message:
                        widget.sourceSyncMessage ??
                        'News API 본문이 짧거나 잘려 있을 수 있어 원문을 한 번 더 확인합니다. 웹에서는 브라우저 제한 때문에 자동으로 전체 본문을 가져오지 못할 수 있습니다.',
                  ),
                if (widget.article.requiresSourceEnrichment ||
                    widget.sourceSyncMessage != null)
                  const SizedBox(height: 18),
                _SectionCard(
                  title: '학습 스크립트',
                  subtitle: '문단 그대로 읽다가 모르는 단어를 누르면 아래에 뜻과 문법 설명 박스가 열립니다.',
                  child: paragraphs.isEmpty
                      ? const _ReaderStatePanel(
                          title: '분석할 스크립트가 없습니다.',
                          message: '스크립트를 붙여 넣으면 단어와 문법을 분석할 수 있습니다.',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedWord == null)
                              const _InlineInfoCard(
                                icon: Icons.touch_app_rounded,
                                title: '단어를 눌러 보세요.',
                                message:
                                    '읽는 흐름을 끊지 않도록 뜻, 문맥, 관련 문법을 같은 위치 근처에서 바로 보여줍니다.',
                              ),
                            if (_selectedWord == null)
                              const SizedBox(height: 18),
                            for (
                              var index = 0;
                              index < paragraphs.length;
                              index++
                            ) ...[
                              _InteractiveParagraph(
                                tokens: paragraphs[index],
                                knownWordIndex: knownWordIndex,
                                wordNoteIndex: wordNoteIndex,
                                selectedNormalized: selectedNormalized,
                                onWordTap: (token) => _selectWord(
                                  token: token,
                                  paragraphIndex: index,
                                  paragraph: paragraphs[index],
                                ),
                              ),
                              if (_selectedWord?.paragraphIndex == index) ...[
                                const SizedBox(height: 14),
                                _WordInsightBox(
                                  token: _selectedWord!.token,
                                  contextSnippet: _selectedWord!.contextSnippet,
                                  knownMatches: selectedKnownMatches,
                                  savedNote: selectedSavedNote,
                                  suggestion: selectedSuggestion!,
                                  dictionaryRepository:
                                      widget.dictionaryRepository,
                                  relatedInsights: selectedRelatedInsights,
                                  pronunciationService:
                                      widget.pronunciationService,
                                  onClose: _clearSelectedWord,
                                  onToggleSaved: (meaningDraft) =>
                                      _toggleSelectedWord(
                                        context,
                                        meaningDraft: meaningDraft,
                                        knownMatches: selectedKnownMatches,
                                      ),
                                  onAddToStudy: (meaningDraft) =>
                                      _openStudyCardSheet(
                                        context,
                                        suggestion: selectedSuggestion,
                                        meaningDraft: meaningDraft,
                                      ),
                                ),
                              ],
                              if (index != paragraphs.length - 1)
                                const SizedBox(height: 20),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: '문법 인사이트',
                  subtitle: '자동으로 잡아낸 패턴을 보며 모르는 문법만 따로 체크할 수 있습니다.',
                  child: grammarInsights.isEmpty
                      ? const _ReaderStatePanel(
                          title: '눈에 띄는 패턴이 아직 없습니다.',
                          message: '스크립트를 더 붙여 넣으면 문법 패턴을 더 많이 잡아낼 수 있습니다.',
                        )
                      : Column(
                          children: grammarInsights.map((insight) {
                            final saved =
                                grammarNoteIndex[insight.id.toLowerCase()] !=
                                null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _GrammarInsightTile(
                                insight: insight,
                                saved: saved,
                                onToggleSaved: () =>
                                    _toggleGrammarInsight(context, insight),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 18),
                if (wordNotes.isNotEmpty) ...[
                  _SectionCard(
                    title: '저장한 모르는 단어',
                    subtitle: '읽는 중 체크한 단어를 다시 볼 수 있습니다.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: wordNotes.map((note) {
                        final meaning = note.meaning?.trim();
                        return _SavedNoteChip(
                          label: note.surfaceText,
                          detail: meaning == null || meaning.isEmpty
                              ? '뜻 메모 없음'
                              : meaning,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (grammarNotes.isNotEmpty)
                  _SectionCard(
                    title: '저장한 모르는 문법',
                    subtitle: '헷갈리는 문법 포인트를 따로 쌓아 둘 수 있습니다.',
                    child: Column(
                      children: grammarNotes.map((note) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SavedGrammarTile(note: note),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, List<VocabWord>> _indexKnownWords(List<VocabWord> words) {
    final index = <String, List<VocabWord>>{};
    for (final word in words) {
      final normalized = ScriptAnalyzer.normalizeWord(word.german);
      if (normalized.isEmpty) {
        continue;
      }
      index.putIfAbsent(normalized, () => <VocabWord>[]).add(word);
    }
    return index;
  }

  void _selectWord({
    required ScriptToken token,
    required int paragraphIndex,
    required List<ScriptToken> paragraph,
  }) {
    setState(() {
      _selectedWord = _SelectedWord(
        paragraphIndex: paragraphIndex,
        token: token,
        contextSnippet: _contextSnippet(
          paragraph: paragraph,
          currentToken: token,
        ),
      );
    });
  }

  void _clearSelectedWord() {
    setState(() => _selectedWord = null);
  }

  Future<void> _openScriptEditor(BuildContext context) async {
    final controller = TextEditingController(text: widget.document.scriptText);
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, inset + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학습 스크립트 편집',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '기사 본문이나 영상 자막을 붙여 넣으면 단어와 문법 분석 정확도가 좋아집니다.',
                    style: TextStyle(height: 1.55, color: Color(0xFF60707F)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    minLines: 10,
                    maxLines: 16,
                    decoration: const InputDecoration(
                      hintText: '뉴스 기사 본문이나 영상 자막을 붙여 넣어 주세요.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('스크립트 저장'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    await widget.repository.updateScript(widget.document.id, controller.text);
    if (!context.mounted) {
      return;
    }
    await widget.onScriptUpdated();
    if (!context.mounted) {
      return;
    }
    setState(() => _selectedWord = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('학습 스크립트를 저장했습니다.')));
  }

  Future<void> _toggleGrammarInsight(
    BuildContext context,
    GrammarInsight insight,
  ) async {
    final saved = await widget.repository.toggleGrammarNote(
      documentId: widget.document.id,
      surfaceText: insight.title,
      normalizedText: insight.id,
      explanation: insight.explanation,
      contextSnippet: insight.snippet,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? '${insight.title} 문법 메모를 저장했습니다.'
              : '${insight.title} 저장을 해제했습니다.',
        ),
      ),
    );
  }

  Future<void> _toggleSelectedWord(
    BuildContext context, {
    required String meaningDraft,
    required List<VocabWord> knownMatches,
  }) async {
    final selection = _selectedWord;
    if (selection == null) {
      return;
    }

    final saved = await widget.repository.toggleWordNote(
      documentId: widget.document.id,
      surfaceText: selection.token.surface,
      normalizedText: selection.token.normalized,
      meaning: meaningDraft,
      explanation: knownMatches.isEmpty
          ? null
          : knownMatches
                .map(
                  (word) =>
                      '${word.german}: ${word.meaningKo} / ${word.meaningEn}',
                )
                .join('\n'),
      contextSnippet: selection.contextSnippet,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? '${selection.token.surface}를 모르는 단어로 저장했습니다.'
              : '${selection.token.surface} 저장을 해제했습니다.',
        ),
      ),
    );
  }

  Future<void> _openStudyCardSheet(
    BuildContext context, {
    required ReadingWordSuggestion? suggestion,
    required String meaningDraft,
  }) async {
    final selection = _selectedWord;
    if (selection == null || suggestion == null) {
      return;
    }

    final initialDraft = suggestion.toStudyWordDraft(
      german: selection.token.surface,
      contextSnippet: selection.contextSnippet,
      meaningKoOverride: meaningDraft,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: AddWordSheet(
          dictionaryRepository: widget.dictionaryRepository,
          repository: widget.studyRepository,
          pronunciationService: widget.pronunciationService,
          initialDraft: initialDraft,
          title: '실전 단어를 학습 카드로 저장',
          subtitle: '자동 제안된 뜻과 문장을 먼저 넣어 두었습니다. 필요한 부분만 수정해서 저장하면 됩니다.',
          submitLabel: '학습 카드 저장',
        ),
      ),
    );
  }

  List<GrammarInsight> _relatedInsights({
    required ScriptToken token,
    required String sentenceSnippet,
    required List<GrammarInsight> allInsights,
  }) {
    final related = <GrammarInsight>[];
    final seen = <String>{};
    final normalized = token.normalized.toLowerCase();

    for (final insight in allInsights) {
      final snippet = insight.snippet.toLowerCase();
      if (!snippet.contains(normalized)) {
        continue;
      }
      final key = '${insight.id}::${insight.snippet}';
      if (seen.add(key)) {
        related.add(insight);
      }
    }

    if (related.isNotEmpty) {
      return related.take(3).toList();
    }

    for (final insight in ScriptAnalyzer.detectGrammarInsights(
      sentenceSnippet,
    )) {
      final key = '${insight.id}::${insight.snippet}';
      if (seen.add(key)) {
        related.add(insight);
      }
    }

    return related.take(3).toList();
  }

  String _contextSnippet({
    required List<ScriptToken> paragraph,
    required ScriptToken currentToken,
  }) {
    final index = paragraph.indexOf(currentToken);
    if (index == -1) {
      return currentToken.surface;
    }

    var start = index;
    while (start > 0 && !_endsSentence(paragraph[start - 1])) {
      start--;
    }

    var end = index;
    while (end < paragraph.length - 1 && !_endsSentence(paragraph[end])) {
      end++;
    }

    return _joinTokens(paragraph.sublist(start, end + 1));
  }

  bool _endsSentence(ScriptToken token) {
    return token.surface == '.' || token.surface == '!' || token.surface == '?';
  }

  String _joinTokens(List<ScriptToken> tokens) {
    final buffer = StringBuffer();
    ScriptToken? previous;

    for (final token in tokens) {
      if (_needsLeadingSpace(previous, token)) {
        buffer.write(' ');
      }
      buffer.write(token.surface);
      previous = token;
    }

    return buffer.toString().trim();
  }
}

class _ArticleHeroCard extends StatelessWidget {
  const _ArticleHeroCard({
    required this.article,
    required this.wordNoteCount,
    required this.grammarNoteCount,
    required this.onEditScript,
    required this.onSpeakTitle,
    required this.onRefreshFromSource,
    required this.isSourceSyncing,
    required this.sourceSyncMessage,
  });

  final NewsArticle article;
  final int wordNoteCount;
  final int grammarNoteCount;
  final Future<void> Function() onEditScript;
  final Future<void> Function() onSpeakTitle;
  final Future<void> Function() onRefreshFromSource;
  final bool isSourceSyncing;
  final String? sourceSyncMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final compact = layout.isCompact;

        return Container(
          padding: EdgeInsets.all(compact ? 18 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 24 : 28),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.sourceName,
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 13 : 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                article.title,
                style: TextStyle(
                  fontSize: compact ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                article.description,
                style: TextStyle(
                  height: 1.55,
                  color: const Color(0xFF536677),
                  fontSize: compact ? 14 : 15,
                ),
                maxLines: compact ? 4 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetaPill(label: '단어 체크 $wordNoteCount개'),
                  _MetaPill(label: '문법 체크 $grammarNoteCount개'),
                  _MetaPill(
                    label: article.requiresSourceEnrichment
                        ? '요약 본문'
                        : '정리된 본문',
                  ),
                ],
              ),
              if (sourceSyncMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  sourceSyncMessage!,
                  style: const TextStyle(
                    color: Color(0xFF60707F),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onEditScript,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('스크립트 수정'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 14 : 16,
                        vertical: compact ? 12 : 14,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSpeakTitle,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('제목 듣기'),
                  ),
                  if (article.requiresSourceEnrichment ||
                      sourceSyncMessage != null)
                    OutlinedButton.icon(
                      onPressed: isSourceSyncing ? null : onRefreshFromSource,
                      icon: Icon(
                        isSourceSyncing
                            ? Icons.sync_rounded
                            : Icons.article_outlined,
                      ),
                      label: Text(isSourceSyncing ? '본문 확인 중' : '원문 본문 확인'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _openOriginalArticle(context, article.url),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('원문 열기'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openOriginalArticle(BuildContext context, String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        return Container(
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(compact ? 24 : 28),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: compact ? 20 : 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  height: 1.55,
                  color: const Color(0xFF60707F),
                  fontSize: compact ? 14 : 15,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _InteractiveParagraph extends StatefulWidget {
  const _InteractiveParagraph({
    required this.tokens,
    required this.knownWordIndex,
    required this.wordNoteIndex,
    required this.selectedNormalized,
    required this.onWordTap,
  });

  final List<ScriptToken> tokens;
  final Map<String, List<VocabWord>> knownWordIndex;
  final Map<String, ReadingNote> wordNoteIndex;
  final String? selectedNormalized;
  final ValueChanged<ScriptToken> onWordTap;

  @override
  State<_InteractiveParagraph> createState() => _InteractiveParagraphState();
}

class _InteractiveParagraphState extends State<_InteractiveParagraph> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final spans = <InlineSpan>[];
    ScriptToken? previous;

    for (final token in widget.tokens) {
      if (_needsLeadingSpace(previous, token)) {
        spans.add(const TextSpan(text: ' '));
      }

      if (!token.isWord) {
        spans.add(TextSpan(text: token.surface));
        previous = token;
        continue;
      }

      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onWordTap(token);
      _recognizers.add(recognizer);

      final normalized = token.normalized.toLowerCase();
      final isKnown = widget.knownWordIndex.containsKey(normalized);
      final isSaved = widget.wordNoteIndex.containsKey(normalized);
      final isSelected = widget.selectedNormalized == normalized;

      spans.add(
        TextSpan(
          text: token.surface,
          recognizer: recognizer,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.ink,
            backgroundColor: isSelected
                ? AppColors.gold.withValues(alpha: 0.28)
                : isSaved
                ? AppColors.coral.withValues(alpha: 0.16)
                : isKnown
                ? AppColors.teal.withValues(alpha: 0.14)
                : Colors.transparent,
          ),
        ),
      );
      previous = token;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 19,
            height: 1.92,
            color: AppColors.ink,
          ),
          children: spans,
        ),
      ),
    );
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}

class _WordInsightBox extends StatefulWidget {
  const _WordInsightBox({
    required this.token,
    required this.contextSnippet,
    required this.knownMatches,
    required this.savedNote,
    required this.suggestion,
    required this.dictionaryRepository,
    required this.relatedInsights,
    required this.pronunciationService,
    required this.onClose,
    required this.onToggleSaved,
    required this.onAddToStudy,
  });

  final ScriptToken token;
  final String contextSnippet;
  final List<VocabWord> knownMatches;
  final ReadingNote? savedNote;
  final ReadingWordSuggestion suggestion;
  final DictionaryRepository dictionaryRepository;
  final List<GrammarInsight> relatedInsights;
  final PronunciationService pronunciationService;
  final VoidCallback onClose;
  final Future<void> Function(String meaningDraft) onToggleSaved;
  final Future<void> Function(String meaningDraft) onAddToStudy;

  @override
  State<_WordInsightBox> createState() => _WordInsightBoxState();
}

class _WordInsightBoxState extends State<_WordInsightBox> {
  late final TextEditingController _meaningController;
  DictionaryAutoFill? _dictionarySuggestion;
  String? _dictionaryError;
  bool _dictionaryNotFound = false;
  bool _isDictionaryLoading = false;
  bool _isSaving = false;
  bool _userEditedMeaning = false;
  bool _suppressMeaningListener = false;
  String _lastAppliedMeaning = '';

  @override
  void initState() {
    super.initState();
    _meaningController = TextEditingController();
    _meaningController.addListener(_handleMeaningChanged);
    _setMeaningText(_initialMeaning());
    _lookupDictionarySuggestion();
  }

  @override
  void didUpdateWidget(covariant _WordInsightBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tokenChanged =
        oldWidget.token.normalized != widget.token.normalized ||
        oldWidget.token.surface != widget.token.surface;
    final savedNoteChanged = oldWidget.savedNote?.id != widget.savedNote?.id;

    if (tokenChanged || savedNoteChanged) {
      _dictionarySuggestion = null;
      _dictionaryError = null;
      _dictionaryNotFound = false;
      _userEditedMeaning = false;
      _setMeaningText(_initialMeaning());
      _lookupDictionarySuggestion();
    }
  }

  @override
  void dispose() {
    _meaningController.removeListener(_handleMeaningChanged);
    _meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
        final compact = layout.maxWidth < 460;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 16 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 22 : 24),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.token.surface,
                      style: TextStyle(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                widget.savedNote == null
                    ? '현재 문단에서 선택한 단어입니다.'
                    : '이미 모르는 단어 메모에 저장되어 있습니다.',
                style: TextStyle(
                  color: const Color(0xFF60707F),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 13 : 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              if (widget.knownMatches.isNotEmpty) ...[
                const Text(
                  '현재 단어장에 있는 뜻',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.knownMatches.map(
                  (word) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '${word.german}  |  ${word.meaningKo} / ${word.meaningEn}',
                        style: const TextStyle(
                          height: 1.5,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const Text(
                  '아직 단어장에 등록된 뜻이 없습니다.',
                  style: TextStyle(height: 1.5, color: Color(0xFF60707F)),
                ),
                const SizedBox(height: 12),
              ],
              _buildDictionaryPanel(),
              const SizedBox(height: 12),
              TextField(
                controller: _meaningController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '뜻 수정 / 메모',
                  hintText: '자동 제안 뜻을 바꾸거나 기억 포인트를 적어 둘 수 있어요.',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '문맥: ${widget.contextSnippet}',
                  style: const TextStyle(
                    height: 1.55,
                    color: Color(0xFF5F6F7C),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '이 단어와 관련된 문법 설명',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              ..._resolvedGrammarNotes().map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        height: 1.5,
                        color: Color(0xFF60707F),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (widget.relatedInsights.isEmpty)
                const Text(
                  '이 문장 주변에서 대표 문법 패턴은 아직 감지되지 않았습니다.',
                  style: TextStyle(height: 1.5, color: Color(0xFF60707F)),
                )
              else
                Column(
                  children: widget.relatedInsights.map((insight) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              insight.explanation,
                              style: const TextStyle(
                                height: 1.5,
                                color: Color(0xFF60707F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => widget.pronunciationService.speak(
                      widget.token.surface,
                      locale: 'de-DE',
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('단어 듣기'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => widget.pronunciationService.speak(
                      widget.contextSnippet,
                      locale: 'de-DE',
                    ),
                    icon: const Icon(Icons.record_voice_over_rounded),
                    label: const Text('문장 듣기'),
                  ),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _toggleSaved,
                    icon: Icon(
                      widget.savedNote == null
                          ? Icons.bookmark_add_rounded
                          : Icons.bookmark_remove_rounded,
                    ),
                    label: Text(
                      widget.savedNote == null ? '모르는 단어 저장' : '저장 해제',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _isSaving ? null : _addToStudy,
                    icon: const Icon(Icons.school_rounded),
                    label: const Text('학습 카드로 저장'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDictionaryPanel() {
    if (_isDictionaryLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '실시간 사전 결과를 가져오는 중입니다.',
                style: TextStyle(height: 1.5, color: AppColors.ink),
              ),
            ),
          ],
        ),
      );
    }

    final dictionarySuggestion = _dictionarySuggestion;
    if (dictionarySuggestion != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dictionaryPanelHeader(
              title: '실시간 사전 추천',
              trailing: dictionarySuggestion.sourceLabel,
            ),
            const SizedBox(height: 8),
            Text(
              '${dictionarySuggestion.meaningKo}  |  ${dictionarySuggestion.meaningEn}',
              style: const TextStyle(
                height: 1.5,
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metaChip(dictionarySuggestion.partOfSpeech),
                if (dictionarySuggestion.article != null &&
                    dictionarySuggestion.article!.trim().isNotEmpty)
                  _metaChip(dictionarySuggestion.article!),
                if (dictionarySuggestion.pronunciation.trim().isNotEmpty)
                  _metaChip(dictionarySuggestion.pronunciation),
              ],
            ),
            if (dictionarySuggestion.forms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '활용형: ${dictionarySuggestion.forms.take(4).join(', ')}',
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (dictionarySuggestion.synonyms.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '유의어: ${dictionarySuggestion.synonyms.take(5).join(', ')}',
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              dictionarySuggestion.usedDefinitionFallbackForKo
                  ? '한국어 번역이 비어 있어 영어 정의를 임시로 함께 보여줍니다.'
                  : '한국어 번역까지 포함된 사전 결과를 기본값으로 사용합니다.',
              style: const TextStyle(height: 1.5, color: Color(0xFF60707F)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openUrl(
                    dictionarySuggestion.sourceUrl,
                    errorMessage: '원문 사전 페이지를 열지 못했습니다.',
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('원문 보기'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openUrl(
                    dictionarySuggestion.licenseUrl,
                    errorMessage: '라이선스 페이지를 열지 못했습니다.',
                  ),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(dictionarySuggestion.licenseName),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _dictionaryNotFound
            ? AppColors.coral.withValues(alpha: 0.08)
            : AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dictionaryPanelHeader(
            title: _dictionaryNotFound ? '실시간 사전' : '자동 제안',
            trailing: _dictionaryNotFound
                ? '사전 미등록'
                : widget.suggestion.sourceLabel,
          ),
          const SizedBox(height: 8),
          if (_dictionaryNotFound) ...[
            const Text(
              '여기 사전에 없습니다.',
              style: TextStyle(
                height: 1.5,
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.suggestion.isApproximate
                  ? '아래 뜻은 형태 기반 자동 추정이므로 저장 전에 한 번 확인해 주세요.'
                  : '아래 뜻은 현재 단어장이나 기본 제안을 바탕으로 보여드리고 있습니다.',
              style: const TextStyle(
                height: 1.5,
                color: Color(0xFF60707F),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            '${widget.suggestion.meaningKo}  |  ${widget.suggestion.meaningEn}',
            style: const TextStyle(
              height: 1.5,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '품사: ${widget.suggestion.partOfSpeech}${widget.suggestion.article == null || widget.suggestion.article!.trim().isEmpty ? '' : '  |  관사: ${widget.suggestion.article}'}',
            style: const TextStyle(
              height: 1.5,
              color: Color(0xFF60707F),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_dictionaryError != null && !_dictionaryNotFound) ...[
            const SizedBox(height: 8),
            Text(
              _dictionaryError!,
              style: const TextStyle(height: 1.5, color: Color(0xFF60707F)),
            ),
          ],
          if (widget.suggestion.isApproximate) ...[
            const SizedBox(height: 6),
            const Text(
              '이 제안은 형태 기반 자동 추정입니다. 저장 전에 뜻을 한 번 수정해 주세요.',
              style: TextStyle(height: 1.5, color: Color(0xFF60707F)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dictionaryPanelHeader({
    required String title,
    required String trailing,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trailing,
                style: const TextStyle(
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                trailing,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF60707F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
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

  List<String> _resolvedGrammarNotes() {
    final notes = <String>[];
    final seen = <String>{};

    void addNote(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return;
      }
      final key = trimmed.toLowerCase();
      if (seen.add(key)) {
        notes.add(trimmed);
      }
    }

    for (final note
        in _dictionarySuggestion?.grammarNotes ?? const <String>[]) {
      addNote(note);
    }

    if (notes.isEmpty) {
      addNote(widget.suggestion.grammarHint);
    }

    return notes;
  }

  String _initialMeaning() {
    final savedMeaning = widget.savedNote?.meaning?.trim();
    if (savedMeaning != null && savedMeaning.isNotEmpty) {
      return savedMeaning;
    }
    final dictionaryMeaning = _dictionarySuggestion?.meaningKo.trim();
    if (dictionaryMeaning != null && dictionaryMeaning.isNotEmpty) {
      return dictionaryMeaning;
    }
    if (widget.knownMatches.isEmpty) {
      return widget.suggestion.meaningKo;
    }
    final first = widget.knownMatches.first;
    return '${first.meaningKo} / ${first.meaningEn}';
  }

  void _handleMeaningChanged() {
    if (_suppressMeaningListener) {
      return;
    }
    _userEditedMeaning = true;
  }

  void _setMeaningText(String text) {
    _suppressMeaningListener = true;
    _meaningController.text = text;
    _meaningController.selection = TextSelection.collapsed(
      offset: _meaningController.text.length,
    );
    _suppressMeaningListener = false;
    _lastAppliedMeaning = text;
  }

  Future<void> _lookupDictionarySuggestion() async {
    final lookupWord = widget.token.surface;
    setState(() {
      _isDictionaryLoading = true;
      _dictionaryError = null;
      _dictionaryNotFound = false;
    });

    try {
      final suggestion = await widget.dictionaryRepository.suggestGermanWord(
        lookupWord,
        contextSnippet: widget.contextSnippet,
      );

      if (!mounted || widget.token.surface != lookupWord) {
        return;
      }

      if (suggestion == null) {
        setState(() {
          _dictionarySuggestion = null;
          _dictionaryError = '여기 사전에 없습니다.';
          _dictionaryNotFound = true;
          _isDictionaryLoading = false;
        });
        return;
      }

      final shouldApplyMeaning =
          !_userEditedMeaning ||
          _meaningController.text.trim().isEmpty ||
          _meaningController.text.trim() == _lastAppliedMeaning.trim();

      setState(() {
        _dictionarySuggestion = suggestion;
        _dictionaryError = null;
        _dictionaryNotFound = false;
        _isDictionaryLoading = false;
      });

      if (shouldApplyMeaning) {
        _setMeaningText(suggestion.meaningKo);
        _userEditedMeaning = false;
      }
    } catch (_) {
      if (!mounted || widget.token.surface != lookupWord) {
        return;
      }
      setState(() {
        _dictionarySuggestion = null;
        _dictionaryNotFound = false;
        _dictionaryError = '실시간 사전 연결에 실패해 기존 제안을 유지합니다.';
        _isDictionaryLoading = false;
      });
    }
  }

  Future<void> _toggleSaved() async {
    setState(() => _isSaving = true);
    try {
      await widget.onToggleSaved(_meaningController.text);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addToStudy() async {
    setState(() => _isSaving = true);
    try {
      await widget.onAddToStudy(_meaningController.text);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openUrl(String rawUrl, {required String errorMessage}) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}

class _GrammarInsightTile extends StatelessWidget {
  const _GrammarInsightTile({
    required this.insight,
    required this.saved,
    required this.onToggleSaved,
  });

  final GrammarInsight insight;
  final bool saved;
  final Future<void> Function() onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: onToggleSaved,
                child: Text(saved ? '저장 해제' : '문법 저장'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.explanation,
            style: const TextStyle(height: 1.55, color: Color(0xFF60707F)),
          ),
          const SizedBox(height: 10),
          Text(
            '예문 조각: ${insight.snippet}',
            style: const TextStyle(
              height: 1.55,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedNoteChip extends StatelessWidget {
  const _SavedNoteChip({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(color: Color(0xFF60707F), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SavedGrammarTile extends StatelessWidget {
  const _SavedGrammarTile({required this.note});

  final ReadingNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.surfaceText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          if (note.explanation != null &&
              note.explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note.explanation!,
              style: const TextStyle(height: 1.55, color: Color(0xFF5F6F7C)),
            ),
          ],
          if (note.contextSnippet != null &&
              note.contextSnippet!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '예문 조각: ${note.contextSnippet!}',
              style: const TextStyle(
                height: 1.55,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReaderStatePanel extends StatelessWidget {
  const _ReaderStatePanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

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

class _InlineInfoCard extends StatelessWidget {
  const _InlineInfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(height: 1.5, color: Color(0xFF60707F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedWord {
  const _SelectedWord({
    required this.paragraphIndex,
    required this.token,
    required this.contextSnippet,
  });

  final int paragraphIndex;
  final ScriptToken token;
  final String contextSnippet;
}

bool _needsLeadingSpace(ScriptToken? previous, ScriptToken current) {
  if (previous == null) {
    return false;
  }

  const noSpaceBefore = <String>{
    '.',
    ',',
    ';',
    ':',
    '!',
    '?',
    ')',
    ']',
    '}',
    '%',
    '"',
    '\'',
  };
  const noSpaceAfter = <String>{'(', '[', '{', '"'};

  if (noSpaceBefore.contains(current.surface)) {
    return false;
  }
  if (noSpaceAfter.contains(previous.surface)) {
    return false;
  }
  return true;
}
