/// Pure Domain Entity: E'lon (Announcement) ob'ekti
class Announcement {
  final String id;
  final String title;
  final String content;
  final String date;
  final bool isImportant;
  final String? bannerUrl;
  final String? authorName;
  final String? groupName;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
    this.bannerUrl,
    this.authorName,
    this.groupName,
  });

  bool get isGroupSpecific => groupName != null && groupName!.isNotEmpty;
  String get body => content;

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? date,
    bool? isImportant,
    String? bannerUrl,
    String? authorName,
    String? groupName,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      isImportant: isImportant ?? this.isImportant,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      authorName: authorName ?? this.authorName,
      groupName: groupName ?? this.groupName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
