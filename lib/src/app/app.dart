import 'package:flutter/material.dart';

import '../core/audio/pronunciation_assessment_service.dart';
import '../core/audio/pronunciation_service.dart';
import '../core/database/app_database.dart';
import '../core/logging/app_logger.dart';
import '../features/dictionary/application/dictionary_repository.dart';
import '../features/immersion/application/immersion_repository.dart';
import '../features/immersion/application/news_feed_repository.dart';
import '../features/study/application/study_repository.dart';
import '../features/study/application/study_coach_service.dart';
import '../features/study/presentation/pages/study_home_page.dart';
import 'app_theme.dart';
import 'responsive_layout.dart';

class DeutschFlowApp extends StatelessWidget {
  const DeutschFlowApp({
    super.key,
    this.database,
    this.pronunciationService,
    this.pronunciationAssessmentService,
    this.studyCoachService,
  });

  final AppDatabase? database;
  final PronunciationService? pronunciationService;
  final PronunciationAssessmentService? pronunciationAssessmentService;
  final StudyCoachService? studyCoachService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppBootstrap(
        database: database,
        pronunciationService: pronunciationService,
        pronunciationAssessmentService: pronunciationAssessmentService,
        studyCoachService: studyCoachService,
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    this.database,
    this.pronunciationService,
    this.pronunciationAssessmentService,
    this.studyCoachService,
  });

  final AppDatabase? database;
  final PronunciationService? pronunciationService;
  final PronunciationAssessmentService? pronunciationAssessmentService;
  final StudyCoachService? studyCoachService;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final AppDatabase _database;
  late final StudyRepository _repository;
  late final DictionaryRepository _dictionaryRepository;
  late final ImmersionRepository _immersionRepository;
  late final NewsFeedRepository _newsFeedRepository;
  late final PronunciationService _pronunciationService;
  late final PronunciationAssessmentService _pronunciationAssessmentService;
  late final StudyCoachService _studyCoachService;
  late final bool _ownsDatabase;
  late final bool _ownsPronunciationService;
  late final bool _ownsPronunciationAssessmentService;
  late final bool _ownsStudyCoachService;
  late final Future<void> _setupFuture;
  Object? _setupError;
  StackTrace? _setupStackTrace;

  @override
  void initState() {
    super.initState();
    _ownsDatabase = widget.database == null;
    _ownsPronunciationService = widget.pronunciationService == null;
    _ownsPronunciationAssessmentService =
        widget.pronunciationAssessmentService == null;
    _ownsStudyCoachService = widget.studyCoachService == null;
    _database = widget.database ?? AppDatabase();
    _repository = StudyRepository(_database);
    _dictionaryRepository = DictionaryRepository();
    _immersionRepository = ImmersionRepository(_database);
    _newsFeedRepository = NewsFeedRepository(database: _database);
    _pronunciationService =
        widget.pronunciationService ?? FlutterTtsPronunciationService();
    _pronunciationAssessmentService =
        widget.pronunciationAssessmentService ??
        SpeechToTextPronunciationAssessmentService();
    _studyCoachService = widget.studyCoachService ?? OpenAiStudyCoachService();
    _setupFuture = _database
        .initialize()
        .then((_) {
          AppLogger.info('AppBootstrap', 'Application bootstrap completed.');
        })
        .catchError((error, stackTrace) {
          _setupError = error;
          _setupStackTrace = stackTrace is StackTrace ? stackTrace : null;
          AppLogger.error(
            'AppBootstrap',
            'Application bootstrap failed.',
            error: error,
            stackTrace: _setupStackTrace,
          );
          throw error;
        });
  }

  @override
  void dispose() {
    _immersionRepository.dispose();
    _newsFeedRepository.dispose();
    _dictionaryRepository.dispose();
    if (_ownsDatabase) {
      _database.close();
    }
    if (_ownsPronunciationService) {
      _pronunciationService.dispose();
    }
    if (_ownsPronunciationAssessmentService) {
      _pronunciationAssessmentService.dispose();
    }
    if (_ownsStudyCoachService) {
      _studyCoachService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _setupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapView(
            title: 'Deutsch Flow',
            message: '로컬 학습 공간과 복습 큐를 준비하고 있어요.',
            loading: true,
          );
        }

        if (snapshot.hasError) {
          return _BootstrapView(
            title: '초기화 실패',
            message:
                'Drift 데이터베이스를 여는 중 문제가 발생했습니다.\n'
                '${_setupError ?? snapshot.error}\n\n'
                '${_shortStack(_setupStackTrace)}',
            loading: false,
          );
        }

        return StudyHomePage(
          repository: _repository,
          dictionaryRepository: _dictionaryRepository,
          immersionRepository: _immersionRepository,
          newsFeedRepository: _newsFeedRepository,
          pronunciationService: _pronunciationService,
          pronunciationAssessmentService: _pronunciationAssessmentService,
          studyCoachService: _studyCoachService,
        );
      },
    );
  }
}

String _shortStack(StackTrace? stackTrace) {
  if (stackTrace == null) {
    return '스택 트레이스를 확인할 수 없습니다.';
  }

  final lines = stackTrace
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .take(4)
      .join('\n');

  return lines.isEmpty ? '스택 트레이스를 확인할 수 없습니다.' : lines;
}

class _BootstrapView extends StatelessWidget {
  const _BootstrapView({
    required this.title,
    required this.message,
    required this.loading,
  });

  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusItems = loading
        ? const [
            _BootstrapStatusItem(
              icon: Icons.storage_rounded,
              title: 'Local storage',
              body: '저장된 단어장과 복습 기록을 안정적으로 불러오는 중입니다.',
            ),
            _BootstrapStatusItem(
              icon: Icons.bolt_rounded,
              title: 'Review queue',
              body: '오늘 다시 볼 카드와 추천 단어를 다시 계산하고 있어요.',
            ),
            _BootstrapStatusItem(
              icon: Icons.record_voice_over_rounded,
              title: 'Speech tools',
              body: '발음 듣기와 점검 화면에 필요한 음성 도구를 준비합니다.',
            ),
          ]
        : const [
            _BootstrapStatusItem(
              icon: Icons.storage_outlined,
              title: 'Database check',
              body: '로컬 데이터베이스 파일과 초기화 상태를 먼저 확인해 주세요.',
            ),
            _BootstrapStatusItem(
              icon: Icons.tune_rounded,
              title: 'Environment',
              body: '개발 환경이나 권한 설정이 달라졌는지 같이 점검하면 좋습니다.',
            ),
            _BootstrapStatusItem(
              icon: Icons.receipt_long_rounded,
              title: 'Error details',
              body: '표시된 메시지와 스택 일부를 기준으로 문제 지점을 빠르게 좁힐 수 있어요.',
            ),
          ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, Color(0xFFF0F7F4), Color(0xFFFFF6EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final layout = ResponsiveLayout.fromConstraints(constraints);
            final content = [
              _BootstrapHeroCard(
                title: title,
                message: message,
                loading: loading,
                theme: theme,
                layout: layout,
              ),
              _BootstrapStatusPanel(
                loading: loading,
                items: statusItems,
                layout: layout,
              ),
            ];

            return SingleChildScrollView(
              padding: EdgeInsets.all(layout.pagePadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (layout.pagePadding * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: layout.isExpanded ? 1080 : 760,
                    ),
                    child: layout.isExpanded
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 5, child: content[0]),
                              const SizedBox(width: 18),
                              Expanded(flex: 3, child: content[1]),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              content[0],
                              const SizedBox(height: 16),
                              content[1],
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BootstrapHeroCard extends StatelessWidget {
  const _BootstrapHeroCard({
    required this.title,
    required this.message,
    required this.loading,
    required this.theme,
    required this.layout,
  });

  final String title;
  final String message;
  final bool loading;
  final ThemeData theme;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final icon = loading
        ? Icons.auto_stories_rounded
        : Icons.warning_amber_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.cardPadding + 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(layout.panelRadius),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: layout.isCompact ? 64 : 72,
                height: layout.isCompact ? 64 : 72,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(
                    layout.isCompact ? 20 : 24,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mist.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  loading ? 'Preparing Deutsch Flow' : 'Check startup state',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.sectionGap),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: layout.displayTitleSize,
            ),
          ),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BootstrapPill(label: loading ? 'Drift 로컬 저장소' : '오류 메시지 확인'),
              _BootstrapPill(label: loading ? '복습 큐 구성' : '환경 설정 점검'),
              _BootstrapPill(label: loading ? '발음 도구 연결' : '재시도 준비'),
            ],
          ),
          SizedBox(height: layout.sectionGap),
          if (loading)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 6),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '앱을 다시 실행하면 초기화가 다시 시도됩니다. 같은 문제가 반복되면 데이터베이스 생성 단계부터 확인해 보세요.',
                style: TextStyle(
                  height: 1.5,
                  color: Color(0xFF5B6C7A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BootstrapStatusPanel extends StatelessWidget {
  const _BootstrapStatusPanel({
    required this.loading,
    required this.items,
    required this.layout,
  });

  final bool loading;
  final List<_BootstrapStatusItem> items;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(layout.panelRadius),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loading ? '현재 준비 중인 항목' : '지금 먼저 볼 항목',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loading
                ? '모든 디바이스에서 같은 학습 상태를 안정적으로 불러오기 위해 초기 구성을 순서대로 진행합니다.'
                : '표시된 내용을 기준으로 원인을 빠르게 좁힐 수 있게 핵심 점검 항목만 남겼습니다.',
            style: const TextStyle(height: 1.55, color: Color(0xFF5E7080)),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BootstrapStatusTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootstrapStatusTile extends StatelessWidget {
  const _BootstrapStatusTile({required this.item});

  final _BootstrapStatusItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.ink.withValues(alpha: 0.1),
            child: Icon(item.icon, size: 20, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
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

class _BootstrapPill extends StatelessWidget {
  const _BootstrapPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
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

class _BootstrapStatusItem {
  const _BootstrapStatusItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
