import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../../../core/audio/voice_locale.dart';
import '../../../dictionary/application/dictionary_repository.dart';
import '../../../dictionary/domain/dictionary_lookup.dart';
import '../../application/study_repository.dart';
import '../../application/study_word_draft.dart';

class AddWordSheet extends StatefulWidget {
  const AddWordSheet({
    super.key,
    required this.dictionaryRepository,
    required this.repository,
    required this.pronunciationService,
    this.initialDraft,
    this.defaultDeck = 'My Deck',
    this.initialIsDailyRecommendation = false,
    this.title = '새 단어 추가',
    this.subtitle = '사전 결과를 먼저 채워 두고, 필요한 부분만 손보는 방식으로 입력 흐름을 다듬었습니다.',
    this.submitLabel = '단어 저장',
  });

  final DictionaryRepository dictionaryRepository;
  final StudyRepository repository;
  final PronunciationService pronunciationService;
  final StudyWordDraft? initialDraft;
  final String defaultDeck;
  final bool initialIsDailyRecommendation;
  final String title;
  final String subtitle;
  final String submitLabel;

  @override
  State<AddWordSheet> createState() => _AddWordSheetState();
}

class _AddWordSheetState extends State<AddWordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _germanController;
  late final TextEditingController _englishController;
  late final TextEditingController _koreanController;
  late final TextEditingController _pronunciationController;
  late final TextEditingController _articleController;
  late final TextEditingController _partOfSpeechController;
  late final TextEditingController _deckController;
  late final TextEditingController _exampleController;
  late final TextEditingController _exampleTranslationController;
  late final TextEditingController _grammarController;

  Timer? _lookupDebounce;

  bool _isSaving = false;
  bool _isSpeaking = false;
  bool _isLookingUp = false;
  bool _isLookupStale = false;
  bool _markAsTodayRecommendation = false;
  String? _lookupError;
  String? _lastLookedUpWord;
  DictionaryAutoFill? _lookupSuggestion;
  late String _selectedTtsLocale;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _germanController = TextEditingController(text: draft?.german ?? '');
    _englishController = TextEditingController(text: draft?.meaningEn ?? '');
    _koreanController = TextEditingController(text: draft?.meaningKo ?? '');
    _pronunciationController = TextEditingController(
      text: draft?.pronunciation ?? '',
    );
    _articleController = TextEditingController(text: draft?.article ?? '');
    _partOfSpeechController = TextEditingController(
      text: draft?.partOfSpeech ?? 'noun',
    );
    _deckController = TextEditingController(
      text: draft?.deck ?? widget.defaultDeck,
    );
    _exampleController = TextEditingController(
      text: draft?.exampleSentence ?? '',
    );
    _exampleTranslationController = TextEditingController(
      text: draft?.exampleTranslation ?? '',
    );
    _grammarController = TextEditingController(text: draft?.grammarNote ?? '');
    _selectedTtsLocale = draft?.ttsLocale ?? defaultVoiceLocaleCode;
    _markAsTodayRecommendation = widget.initialIsDailyRecommendation;
    _germanController.addListener(_handleGermanChanged);

    if (_germanController.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _lookupWord(auto: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _germanController.removeListener(_handleGermanChanged);
    _germanController.dispose();
    _englishController.dispose();
    _koreanController.dispose();
    _pronunciationController.dispose();
    _articleController.dispose();
    _partOfSpeechController.dispose();
    _deckController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    _grammarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);
    final selectedVoice = voiceLocaleFromCode(_selectedTtsLocale);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, 18, 22, bottomInset + 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 30,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.subtitle, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                _buildLookupPanel(),
                const SizedBox(height: 18),
                _section(
                  title: '기본 정보',
                  subtitle: '단어를 입력하면 잠시 후 사전 결과를 불러오고, 여기서 바로 발음도 확인할 수 있습니다.',
                  children: [
                    TextFormField(
                      controller: _germanController,
                      validator: _required,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _lookupWord(forceRefresh: true),
                      decoration: InputDecoration(
                        labelText: '독일어',
                        hintText: '예: Rechnung',
                        helperText:
                            '입력을 잠시 멈추면 자동 조회되고, 오른쪽 버튼으로 즉시 다시 찾을 수 있어요.',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _isLookingUp
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () =>
                                      _lookupWord(forceRefresh: true),
                                  icon: const Icon(
                                    Icons.travel_explore_rounded,
                                  ),
                                  tooltip: '사전 다시 조회',
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLookingUp
                              ? null
                              : () => _lookupWord(forceRefresh: true),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(_isLookingUp ? '조회 중...' : '사전으로 자동 채우기'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSpeaking ? null : _previewPronunciation,
                          icon: Icon(
                            _isSpeaking
                                ? Icons.graphic_eq_rounded
                                : Icons.volume_up_rounded,
                          ),
                          label: Text(
                            _isSpeaking
                                ? '재생 중...'
                                : '${selectedVoice.displayLabel} 음성으로 듣기',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTtsLocale,
                      decoration: const InputDecoration(
                        labelText: 'TTS 언어 / 국가',
                        hintText: '발음에 사용할 음성을 선택하세요',
                      ),
                      items: supportedVoiceLocales.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.code,
                          child: Text(
                            '${option.displayLabel} (${option.code})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedTtsLocale = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: '뜻과 카드 정보',
                  subtitle:
                      '자동으로 채워진 값 위에 바로 손을 대면 되도록 자주 수정하는 필드만 한 번에 묶었습니다.',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _articleController,
                            label: '관사',
                            hintText: 'der / die / das',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _partOfSpeechController,
                            label: '품사',
                            hintText: 'noun / verb / adjective',
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _englishController,
                            label: '영어 뜻',
                            hintText: 'bill, invoice',
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _koreanController,
                            label: '한국어 뜻',
                            hintText: '계산서',
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _pronunciationController,
                            label: '발음 메모',
                            hintText: '레흐눙 / /ˈʁɛçnʊŋ/',
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _deckController,
                            label: '덱 이름',
                            hintText: 'Travel / Work / My Deck',
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: '문법 포인트',
                  subtitle:
                      '사전에 품사, 문법 태그, 활용형이 있으면 자동으로 요약해서 가져오고, 필요하면 직접 덧붙일 수 있습니다.',
                  children: [
                    _field(
                      controller: _grammarController,
                      label: '문법 메모',
                      hintText: '관사, 격, 활용형, 어순 포인트를 적어 두세요',
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile.adaptive(
                      value: _markAsTodayRecommendation,
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.ink,
                      title: const Text(
                        '오늘의 추천 단어로 등록',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      subtitle: const Text(
                        '홈 대시보드의 오늘 추천 섹션에 바로 나타나서 매일 따로 모아볼 수 있습니다.',
                        style: TextStyle(
                          height: 1.45,
                          color: Color(0xFF5E6F7C),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _markAsTodayRecommendation = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: '예문',
                  subtitle:
                      '사전 예문을 기본값으로 넣되, 기사 문맥이나 내가 외우기 쉬운 문장으로 자유롭게 바꿀 수 있습니다.',
                  children: [
                    _field(
                      controller: _exampleController,
                      label: '독일어 예문',
                      hintText: 'Kann ich bitte die Rechnung bekommen?',
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      controller: _exampleTranslationController,
                      label: '예문 해석',
                      hintText: '계산서 좀 받을 수 있을까요?',
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isSaving ? '저장 중...' : widget.submitLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLookupPanel() {
    final suggestion = _lookupSuggestion;
    final hasSuggestion = suggestion != null;
    final statusLabel = _isLookingUp
        ? '조회 중'
        : _isLookupStale
        ? '입력 변경됨'
        : hasSuggestion
        ? '자동 채움 적용됨'
        : '사전 대기';
    final statusColor = _isLookingUp
        ? AppColors.gold
        : _isLookupStale
        ? AppColors.coral
        : hasSuggestion
        ? AppColors.teal
        : AppColors.ink;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            AppColors.mist.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사전 자동 채움',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Free Dictionary API 결과를 뜻, 품사, 발음, 예문 초안으로 바로 반영합니다.',
                      style: TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildLookupBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildLookupBody() {
    if (_isLookingUp) {
      return const Row(
        key: ValueKey('lookup-loading'),
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '사전에서 뜻과 예문을 불러오는 중입니다.',
              style: TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
            ),
          ),
        ],
      );
    }

    if (_lookupError != null) {
      return Container(
        key: const ValueKey('lookup-error'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _lookupError!,
          style: const TextStyle(height: 1.5, color: AppColors.ink),
        ),
      );
    }

    final suggestion = _lookupSuggestion;
    if (suggestion == null) {
      return const Text(
        '독일어 단어를 입력하면 잠시 후 자동 조회됩니다. 자동 결과가 마음에 들지 않으면 아래 입력란에서 바로 수정하면 됩니다.',
        key: ValueKey('lookup-empty'),
        style: TextStyle(height: 1.55, color: Color(0xFF5E6F7C)),
      );
    }

    final fallbackNote = suggestion.usedDefinitionFallbackForKo
        ? '한국어 번역이 비어 있어 영어 정의를 한국어 뜻 칸의 임시값으로 넣었습니다.'
        : '한국어 번역도 함께 들어와 있어 바로 저장 초안으로 쓰기 좋습니다.';

    return Column(
      key: const ValueKey('lookup-filled'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${suggestion.meaningKo}  |  ${suggestion.meaningEn}',
          style: const TextStyle(
            fontSize: 16,
            height: 1.55,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _metaChip(Icons.sell_outlined, suggestion.partOfSpeech),
            if (suggestion.article != null && suggestion.article!.isNotEmpty)
              _metaChip(Icons.auto_stories_outlined, suggestion.article!),
            if (suggestion.pronunciation.trim().isNotEmpty)
              _metaChip(Icons.graphic_eq_rounded, suggestion.pronunciation),
          ],
        ),
        if (suggestion.forms.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            '활용형: ${suggestion.forms.take(4).join(', ')}',
            style: const TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
          ),
        ],
        if (suggestion.synonyms.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '유의어: ${suggestion.synonyms.take(5).join(', ')}',
            style: const TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          fallbackNote,
          style: const TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
        ),
        if (suggestion.grammarNotes.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            '문법 포인트',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          ...suggestion.grammarNotes
              .take(3)
              .map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        height: 1.5,
                        color: Color(0xFF5E6F7C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => _openUrl(
                suggestion.sourceUrl,
                errorMessage: '원문 사전 페이지를 열지 못했습니다.',
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('원문 보기'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openUrl(
                suggestion.licenseUrl,
                errorMessage: '라이선스 페이지를 열지 못했습니다.',
              ),
              icon: const Icon(Icons.verified_outlined),
              label: Text(suggestion.licenseName),
            ),
          ],
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
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
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(height: 1.5, color: Color(0xFF5E6F7C)),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.ink),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }

  void _handleGermanChanged() {
    _lookupDebounce?.cancel();
    final word = _germanController.text.trim();

    if (word.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lookupSuggestion = null;
        _lookupError = null;
        _lastLookedUpWord = null;
        _isLookupStale = false;
      });
      return;
    }

    final isStale = _lastLookedUpWord != null && _lastLookedUpWord != word;
    if (mounted && _isLookupStale != isStale) {
      setState(() => _isLookupStale = isStale);
    }

    if (word.length < 2 || word == _lastLookedUpWord) {
      return;
    }

    _lookupDebounce = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        _lookupWord(auto: true);
      }
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목입니다.';
    }
    return null;
  }

  Future<void> _lookupWord({
    bool auto = false,
    bool forceRefresh = false,
  }) async {
    final word = _germanController.text.trim();
    if (word.isEmpty) {
      if (!auto && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('먼저 독일어 단어를 입력해 주세요.')));
      }
      return;
    }

    setState(() {
      _isLookingUp = true;
      _lookupError = null;
    });

    try {
      final suggestion = await widget.dictionaryRepository.suggestGermanWord(
        word,
        contextSnippet: _initialContextExample(),
        forceRefresh: forceRefresh,
      );

      if (!mounted || _germanController.text.trim() != word) {
        return;
      }

      if (suggestion == null) {
        setState(() {
          _lookupSuggestion = null;
          _lookupError = '"$word"는 여기 사전에 없습니다. 뜻을 직접 입력해 주세요.';
          _lastLookedUpWord = word;
          _isLookupStale = false;
        });
        return;
      }

      _applyLookupSuggestion(suggestion);
      setState(() {
        _lookupSuggestion = suggestion;
        _lookupError = null;
        _lastLookedUpWord = word;
        _isLookupStale = false;
      });
    } catch (error) {
      if (!mounted || _germanController.text.trim() != word) {
        return;
      }
      setState(() {
        _lookupError = '$error';
      });
    } finally {
      if (mounted && _germanController.text.trim() == word) {
        setState(() => _isLookingUp = false);
      }
    }
  }

  void _applyLookupSuggestion(DictionaryAutoFill suggestion) {
    _englishController.text = suggestion.meaningEn;
    _koreanController.text = suggestion.meaningKo;
    _pronunciationController.text = suggestion.pronunciation;
    _articleController.text = suggestion.article ?? '';
    _partOfSpeechController.text = suggestion.partOfSpeech;
    _exampleController.text = _preferredExampleSentence(suggestion);
    _exampleTranslationController.text = _preferredExampleTranslation(
      suggestion,
    );
    _grammarController.text = _preferredGrammarNote(suggestion);
  }

  String _preferredExampleSentence(DictionaryAutoFill suggestion) {
    final initialSentence = widget.initialDraft?.exampleSentence.trim() ?? '';
    if (_lastLookedUpWord == null && initialSentence.isNotEmpty) {
      return initialSentence;
    }
    return suggestion.exampleSentence;
  }

  String _preferredExampleTranslation(DictionaryAutoFill suggestion) {
    final initialTranslation =
        widget.initialDraft?.exampleTranslation.trim() ?? '';
    if (_lastLookedUpWord == null && initialTranslation.isNotEmpty) {
      return initialTranslation;
    }
    return suggestion.exampleTranslation;
  }

  String _preferredGrammarNote(DictionaryAutoFill suggestion) {
    final initialGrammar = widget.initialDraft?.grammarNote?.trim() ?? '';
    if (_lastLookedUpWord == null && initialGrammar.isNotEmpty) {
      return initialGrammar;
    }
    return suggestion.grammarNote;
  }

  String? _initialContextExample() {
    final example = widget.initialDraft?.exampleSentence.trim();
    if (example == null || example.isEmpty) {
      return null;
    }
    return example;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final german = _germanController.text.trim();

    try {
      await widget.repository.addWord(
        german: _germanController.text,
        meaningEn: _englishController.text,
        meaningKo: _koreanController.text,
        pronunciation: _pronunciationController.text,
        ttsLocale: _selectedTtsLocale,
        article: _articleController.text,
        partOfSpeech: _partOfSpeechController.text,
        exampleSentence: _exampleController.text,
        exampleTranslation: _exampleTranslationController.text,
        deck: _deckController.text,
        grammarNote: _grammarController.text,
        isDailyRecommendation: _markAsTodayRecommendation,
      );

      if (!mounted) {
        return;
      }

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _markAsTodayRecommendation
                ? '$german를 추가하고 오늘 추천에도 올려두었어요.'
                : '$german를 추가했어요.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('단어를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.\n$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _previewPronunciation() async {
    if (_germanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 독일어 단어를 입력해 주세요.')));
      return;
    }

    setState(() => _isSpeaking = true);

    try {
      await widget.pronunciationService.speak(
        _germanController.text,
        locale: _selectedTtsLocale,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 기기에서 발음 재생을 시작하지 못했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
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
