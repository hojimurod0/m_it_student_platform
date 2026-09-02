class LegalDocumentModel {
  const LegalDocumentModel({
    required this.title,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String summary;
  final List<LegalSectionModel> sections;

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawSections = data['sections'] as List<dynamic>? ?? [];
    return LegalDocumentModel(
      title: (data['title'] ?? '').toString(),
      lastUpdated: (data['last_updated'] ?? '').toString(),
      summary: (data['summary'] ?? '').toString(),
      sections: rawSections
          .map((s) => LegalSectionModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LegalSectionModel {
  const LegalSectionModel({
    required this.heading,
    required this.content,
  });

  final String heading;
  final String content;

  factory LegalSectionModel.fromJson(Map<String, dynamic> json) {
    return LegalSectionModel(
      heading: (json['heading'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }
}
