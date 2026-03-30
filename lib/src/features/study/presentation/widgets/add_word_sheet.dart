import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/audio/pronunciation_service.dart';
import '../../application/study_repository.dart';

class AddWordSheet extends StatefulWidget {
  const AddWordSheet({
    super.key,
    required this.repository,
    required this.pronunciationService,
  });

  final StudyRepository repository;
  final PronunciationService pronunciationService;

  @override
  State<AddWordSheet> createState() => _AddWordSheetState();
}

class _AddWordSheetState extends State<AddWordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _germanController = TextEditingController();
  final _englishController = TextEditingController();
  final _koreanController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _articleController = TextEditingController();
  final _partOfSpeechController = TextEditingController(text: 'noun');
  final _deckController = TextEditingController(text: 'My Deck');
  final _exampleController = TextEditingController();
  final _exampleTranslationController = TextEditingController();

  bool _isSaving = false;
  bool _isSpeaking = false;

  @override
  void dispose() {
    _germanController.dispose();
    _englishController.dispose();
    _koreanController.dispose();
    _pronunciationController.dispose();
    _articleController.dispose();
    _partOfSpeechController.dispose();
    _deckController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                const Text(
                  '새 단어 추가',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '추가한 단어는 바로 복습 큐로 들어가도록 설정됩니다.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF5B6D7D),
                  ),
                ),
                const SizedBox(height: 20),
                _field(
                  controller: _germanController,
                  label: '독일어',
                  hintText: '예: Rechnung',
                  validator: _required,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _isSpeaking ? null : _previewPronunciation,
                    icon: Icon(
                      _isSpeaking
                          ? Icons.graphic_eq_rounded
                          : Icons.volume_up_rounded,
                    ),
                    label: Text(_isSpeaking ? '재생 중...' : '입력한 단어 발음 듣기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
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
                        hintText: '레흐눙',
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
                const SizedBox(height: 14),
                _field(
                  controller: _exampleController,
                  label: '독일어 예문',
                  hintText: 'Kann ich bitte die Rechnung bekommen?',
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _exampleTranslationController,
                  label: '예문 해석',
                  hintText: '계산서 좀 받을 수 있을까요?',
                  minLines: 2,
                  maxLines: 3,
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
                    label: Text(_isSaving ? '저장 중...' : '단어 저장'),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목입니다.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    await widget.repository.addWord(
      german: _germanController.text,
      meaningEn: _englishController.text,
      meaningKo: _koreanController.text,
      pronunciation: _pronunciationController.text,
      article: _articleController.text,
      partOfSpeech: _partOfSpeechController.text,
      exampleSentence: _exampleController.text,
      exampleTranslation: _exampleTranslationController.text,
      deck: _deckController.text,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_germanController.text}를 추가했어요.')),
    );
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
      await widget.pronunciationService.speakGerman(_germanController.text);
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
}
