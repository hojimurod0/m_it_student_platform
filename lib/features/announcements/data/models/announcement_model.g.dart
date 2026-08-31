// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      isImportant: json['is_important'] as bool? ?? false,
      bannerUrl: json['banner_url'] as String?,
      authorName: json['author_name'] as String?,
      groupName: json['group_name'] as String?,
    );

Map<String, dynamic> _$AnnouncementModelToJson(AnnouncementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'date': instance.date,
      'is_important': instance.isImportant,
      'banner_url': instance.bannerUrl,
      'author_name': instance.authorName,
      'group_name': instance.groupName,
    };
