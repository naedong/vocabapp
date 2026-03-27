import 'package:flutter/material.dart';

import 'data/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocabApp());
}

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Starter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const BootstrapPage(),
    );
  }
}

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  late final AppDatabase _database;
  late final Future<void> _setupFuture;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _setupFuture = _database.setup();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _setupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('DB 초기화 실패: ${snapshot.error}')),
          );
        }

        return VocabHomePage(database: _database);
      },
    );
  }
}

class VocabHomePage extends StatelessWidget {
  const VocabHomePage({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('독일어 앱 초기 구성 (Drift 연결 완료)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await database.addWord(
            german: 'Haus',
            meaningEn: 'house',
            meaningKo: '집',
            pronunciationEn: 'house',
            pronunciationKo: '하우스',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('샘플 단어 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flutter + Drift 기본 연동 상태입니다.\n아래 목록은 로컬 DB(vocab.sqlite)에서 스트림으로 읽어옵니다.',
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: database.countWords(),
              builder: (context, snapshot) {
                return Text('저장된 단어 수: ${snapshot.data ?? 0}');
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<VocabWord>>(
                stream: database.watchWords(),
                builder: (context, snapshot) {
                  final words = snapshot.data ?? [];
                  if (words.isEmpty) {
                    return const Center(child: Text('아직 저장된 단어가 없습니다.'));
                  }
                  return ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return Card(
                        child: ListTile(
                          title: Text(word.german),
                          subtitle: Text(
                            'EN: ${word.meaningEn} (${word.pronunciationEn})\n'
                            'KO: ${word.meaningKo} (${word.pronunciationKo})',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
