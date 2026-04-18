import 'package:flutter/material.dart';

import '../core/audio/pronunciation_assessment_service.dart';
import '../core/audio/pronunciation_service.dart';
import '../core/database/app_database.dart';
import '../core/localization/app_locale.dart';
import '../core/logging/app_logger.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/app_settings_repository.dart';
import '../core/settings/app_settings_scope.dart';
import '../features/dictionary/application/dictionary_repository.dart';
import '../features/immersion/application/immersion_repository.dart';
import '../features/immersion/application/news_feed_repository.dart';
import '../features/study/application/generative_text_service.dart';
import '../features/study/application/study_repository.dart';
import '../features/study/application/study_coach_service.dart';
import '../features/study/presentation/pages/study_home_page.dart';
import 'app_theme.dart';
import 'responsive_layout.dart';

class DeutschFlowApp extends StatefulWidget {
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
  State<DeutschFlowApp> createState() => _DeutschFlowAppState();
}

class _DeutschFlowAppState extends State<DeutschFlowApp> {
  @override
  void initState() {
    super.initState();
    AppLocalization.instance.onTranslatedLanguage = (_) {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocale.resolveCode(
        AppLocalization.instance.currentLocale?.languageCode,
        AppLocale.appTitle,
      ),
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalization.instance.supportedLocales,
      localizationsDelegates: AppLocalization.instance.localizationsDelegates,
      theme: AppTheme.light(),
      home: AppBootstrap(
        database: widget.database,
        pronunciationService: widget.pronunciationService,
        pronunciationAssessmentService: widget.pronunciationAssessmentService,
        studyCoachService: widget.studyCoachService,
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
  late final AppSettingsRepository _appSettingsRepository;
  late final HybridGenerativeTextService _generativeTextService;
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
    _appSettingsRepository = AppSettingsRepository(_database);
    _generativeTextService = HybridGenerativeTextService();
    _dictionaryRepository = DictionaryRepository(
      generativeTextService: _generativeTextService,
    );
    _immersionRepository = ImmersionRepository(_database);
    _newsFeedRepository = NewsFeedRepository(database: _database);
    _pronunciationService =
        widget.pronunciationService ?? FlutterTtsPronunciationService();
    _pronunciationAssessmentService =
        widget.pronunciationAssessmentService ??
        SpeechToTextPronunciationAssessmentService();
    _studyCoachService =
        widget.studyCoachService ??
        AiStudyCoachService(generativeTextService: _generativeTextService);
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
    _generativeTextService.dispose();
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
            message: 'Preparing your local study space and review queue.',
            loading: true,
          );
        }

        if (snapshot.hasError) {
          return _BootstrapView(
            title: 'Initialization failed',
            message:
                'A problem occurred while opening the Drift database.\n'
                '${_setupError ?? snapshot.error}\n\n'
                '${_shortStack(_setupStackTrace)}',
            loading: false,
          );
        }

        return StreamBuilder<AppSettingsData>(
          stream: _appSettingsRepository.watchSettings(),
          initialData: AppSettingsData.defaults,
          builder: (context, settingsSnapshot) {
            final settings = settingsSnapshot.data ?? AppSettingsData.defaults;
            AppLocalization.syncLanguageCode(settings.appLanguage.code);

            return AppSettingsScope(
              settings: settings,
              child: StudyHomePage(
                repository: _repository,
                dictionaryRepository: _dictionaryRepository,
                immersionRepository: _immersionRepository,
                newsFeedRepository: _newsFeedRepository,
                pronunciationService: _pronunciationService,
                pronunciationAssessmentService: _pronunciationAssessmentService,
                studyCoachService: _studyCoachService,
                appSettingsRepository: _appSettingsRepository,
                settings: settings,
              ),
            );
          },
        );
      },
    );
  }
}

String _shortStack(StackTrace? stackTrace) {
  if (stackTrace == null) {
    return 'No stack trace available.';
  }

  final lines = stackTrace
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .take(4)
      .join('\n');

  return lines.isEmpty ? 'No stack trace available.' : lines;
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
              body:
                  'Loading saved cards and review history from local storage.',
            ),
            _BootstrapStatusItem(
              icon: Icons.bolt_rounded,
              title: 'Review queue',
              body:
                  'Rebuilding today\'s review queue and saved recommendations.',
            ),
            _BootstrapStatusItem(
              icon: Icons.record_voice_over_rounded,
              title: 'Speech tools',
              body:
                  'Preparing the speech tools used for listening and pronunciation checks.',
            ),
          ]
        : const [
            _BootstrapStatusItem(
              icon: Icons.storage_outlined,
              title: 'Database check',
              body:
                  'Check the local database file and its initialization state first.',
            ),
            _BootstrapStatusItem(
              icon: Icons.tune_rounded,
              title: 'Environment',
              body:
                  'It may help to verify whether permissions or environment settings changed.',
            ),
            _BootstrapStatusItem(
              icon: Icons.receipt_long_rounded,
              title: 'Error details',
              body:
                  'Use the message and short stack trace to narrow the failure point quickly.',
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
              _BootstrapPill(
                label: loading ? 'Drift local store' : 'Check error message',
              ),
              _BootstrapPill(
                label: loading ? 'Review queue' : 'Inspect environment',
              ),
              _BootstrapPill(label: loading ? 'Speech tools' : 'Prepare retry'),
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
                'Restarting the app will retry initialization. If the same issue repeats, start by checking database creation.',
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
            loading ? 'Preparing now' : 'Check first',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loading
                ? 'Initial setup runs in sequence so the same study state can load reliably across devices.'
                : 'Only the key checkpoints are shown so you can narrow down the cause quickly.',
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
