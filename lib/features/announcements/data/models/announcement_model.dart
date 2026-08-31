import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/announcements/domain/entities/announcement.dart';

part 'announcement_model.g.dart';

@JsonSerializable()
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
    this.bannerUrl,
    this.authorName,
    this.groupName,
  });

  final String id;
  final String title;
  final String content;
  final String date;
  @JsonKey(name: 'is_important', defaultValue: false)
  final bool isImportant;
  @JsonKey(name: 'banner_url')
  final String? bannerUrl;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'group_name')
  final String? groupName;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['title'] = json['title']?.toString() ?? json['name']?.toString() ?? 'E\'lon';
    sanitized['content'] = json['content']?.toString() ?? json['body']?.toString() ?? json['description']?.toString() ?? '';
    sanitized['date'] = json['date']?.toString() ?? json['created_at']?.toString() ?? '';
    sanitized['is_important'] = json['is_important'] == true || json['isImportant'] == true || json['important'] == true;
    sanitized['banner_url'] = json['banner_url']?.toString() ?? json['image']?.toString() ?? json['photo']?.toString();
    sanitized['author_name'] = json['author_name']?.toString() ?? json['created_by_name']?.toString() ?? json['author']?.toString() ?? 'M-IT Ma\'muriyati';
    sanitized['group_name'] = json['group_name']?.toString() ?? json['group']?.toString();
    return _$AnnouncementModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        content: content,
        date: date,
        isImportant: isImportant,
        bannerUrl: bannerUrl,
        authorName: authorName,
        groupName: groupName,
      );

  factory AnnouncementModel.fromEntity(Announcement entity) => AnnouncementModel(
        id: entity.id,
        title: entity.title,
        content: entity.content,
        date: entity.date,
        isImportant: entity.isImportant,
        bannerUrl: entity.bannerUrl,
        authorName: entity.authorName,
        groupName: entity.groupName,
      );
}
