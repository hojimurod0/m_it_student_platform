import 'package:json_annotation/json_annotation.dart';

part 'ai_mentor_model.g.dart';

enum AiQueryCategory {
  @JsonValue('flutter')
  flutter,
  @JsonValue('dart')
  dart,
  @JsonValue('python')
  python,
  @JsonValue('web')
  web,
  @JsonValue('backend')
  backend,
  @JsonValue('git')
  git,
  @JsonValue('database')
  database,
  @JsonValue('debugging')
  debugging,
  @JsonValue('academy')
  academy,
  @JsonValue('general')
  general,
}

@JsonSerializable()
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
  @JsonKey(defaultValue: true)
  final bool isAi;
  @JsonKey(unknownEnumValue: AiQueryCategory.general, defaultValue: AiQueryCategory.general)
  final AiQueryCategory category;
  final String? codeSnippet;
  final String? codeLanguage;
  @JsonKey(defaultValue: [])
  final List<String> followUpPrompts;
  final bool? helpfulVote;

  factory AiMentorMessage.fromJson(Map<String, dynamic> json) => _$AiMentorMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AiMentorMessageToJson(this);

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
