enum LearningResourceType { news, video, grammar }

class LearningResource {
  const LearningResource({
    required this.id,
    required this.type,
    required this.source,
    required this.title,
    required this.description,
    required this.level,
    required this.format,
    required this.useCase,
    required this.url,
    required this.tags,
  });

  final String id;
  final LearningResourceType type;
  final String source;
  final String title;
  final String description;
  final String level;
  final String format;
  final String useCase;
  final String url;
  final List<String> tags;
}
