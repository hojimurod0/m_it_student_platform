enum AiQueryCategory {
  flutter,
  dart,
  python,
  web,
  backend,
  git,
  database,
  debugging,
  academy,
  general,
}

class AiMentorMessage {
  const AiMentorMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isUser,
    this.isAi = true,
    this.category = AiQueryCategory.general,
    this.codeSnippet,
    this.codeLanguage,
    this.followUpPrompts = const [],
    this.helpfulVote,
  });

  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isUser;
  final bool isAi;
  final AiQueryCategory category;
  final String? codeSnippet;
  final String? codeLanguage;
  final List<String> followUpPrompts;
  final bool? helpfulVote;

  AiMentorMessage copyWith({
    String? id,
    String? senderName,
    String? text,
    String? time,
    bool? isUser,
    bool? isAi,
    AiQueryCategory? category,
    String? codeSnippet,
    String? codeLanguage,
    List<String>? followUpPrompts,
    bool? helpfulVote,
  }) {
    return AiMentorMessage(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      time: time ?? this.time,
      isUser: isUser ?? this.isUser,
      isAi: isAi ?? this.isAi,
      category: category ?? this.category,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      followUpPrompts: followUpPrompts ?? this.followUpPrompts,
      helpfulVote: helpfulVote ?? this.helpfulVote,
    );
  }
}
