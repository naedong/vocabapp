import 'package:flutter/material.dart';

import '../core/audio/pronunciation_service.dart';
import '../core/database/app_database.dart';
import '../core/logging/app_logger.dart';
import '../features/dictionary/application/dictionary_repository.dart';
import '../features/immersion/application/immersion_repository.dart';
import '../features/immersion/application/news_feed_repository.dart';
import '../features/study/application/study_repository.dart';
import '../features/study/presentation/pages/study_home_page.dart';
import 'app_theme.dart';

class DeutschFlowApp extends StatelessWidget {
  const DeutschFlowApp({super.key, this.database, this.pronunciationService});

  final AppDatabase? database;
  final PronunciationService? pronunciationService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppBootstrap(
        database: database,
        pronunciationService: pronunciationService,
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.database, this.pronunciationService});

  final AppDatabase? database;
  final PronunciationService? pronunciationService;

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
  late final bool _ownsDatabase;
  late final bool _ownsPronunciationService;
  late final Future<void> _setupFuture;
  Object? _setupError;
  StackTrace? _setupStackTrace;

  @override
  void initState() {
    super.initState();
    _ownsDatabase = widget.database == null;
    _ownsPronunciationService = widget.pronunciationService == null;
    _database = widget.database ?? AppDatabase();
    _repository = StudyRepository(_database);
    _dictionaryRepository = DictionaryRepository();
    _immersionRepository = ImmersionRepository(_database);
    _newsFeedRepository = NewsFeedRepository(database: _database);
    _pronunciationService =
        widget.pronunciationService ?? FlutterTtsPronunciationService();
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.ink.withValues(alpha: 0.06),
                      ),
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
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            loading
                                ? Icons.auto_stories_rounded
                                : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(title, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (loading) ...[
                          const SizedBox(height: 24),
                          const CircularProgressIndicator(strokeWidth: 3),
                        ],
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
