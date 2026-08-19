class ItNewsArticle {
  const ItNewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.coverImageUrl,
    required this.publishedAt,
    required this.readingTimeMinutes,
    required this.tags,
    required this.reactions,
    required this.authorName,
    required this.authorAvatar,
    required this.sourceName,
    required this.sourceBadge,
    required this.sourceUrl,
  });

  final String id;
  final String title;
  final String description;
  final String url;
  final String? coverImageUrl;
  final String publishedAt;
  final int readingTimeMinutes;
  final List<String> tags;
  final int reactions;
  final String authorName;
  final String? authorAvatar;
  final String sourceName;
  final String sourceBadge;
  final String sourceUrl;

  /// Rasmli yoki yo'qligini aniqlash
  bool get hasCoverImage =>
      coverImageUrl != null && coverImageUrl!.isNotEmpty;

  /// Dev.to JSON formatidan parsing
  factory ItNewsArticle.fromJson(Map<String, dynamic> json) {
    final tagList = (json['tag_list'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [];

    final user = json['user'] as Map<String, dynamic>? ?? {};
    final coverImg = json['cover_image'] as String? ??
        json['social_image'] as String?;

    return ItNewsArticle(
      id: '${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      title: _cleanText(json['title'] as String? ?? ''),
      description: _cleanText(json['description'] as String? ?? ''),
      url: json['url'] as String? ?? 'https://dev.to',
      coverImageUrl: (coverImg != null && coverImg.isNotEmpty) ? coverImg : null,
      publishedAt: json['published_at'] as String? ?? '',
      readingTimeMinutes: json['reading_time_minutes'] as int? ?? 2,
      tags: tagList,
      reactions: json['positive_reactions_count'] as int? ?? 12,
      authorName: (user['name'] as String? ?? 'Dev.to').trim(),
      authorAvatar: user['profile_image_90'] as String?,
      sourceName: 'Dev.to Community',
      sourceBadge: 'Xalqaro Dasturchilar',
      sourceUrl: 'https://dev.to',
    );
  }

  /// RSS2JSON formatidan parsing (Spot.uz, Kun.uz, TechCrunch, Medium Flutter)
  factory ItNewsArticle.fromRssJson(
    Map<String, dynamic> item, {
    required String sourceName,
    required String sourceBadge,
    required String sourceUrl,
    String? defaultCover,
  }) {
    // 1. Rasmni aniqlash (enclosure -> thumbnail -> content ichidagi <img>)
    String? coverUrl;
    final enclosure = item['enclosure'] as Map<String, dynamic>?;
    if (enclosure != null && enclosure['link'] != null) {
      final link = enclosure['link'].toString();
      if (link.startsWith('http')) {
        coverUrl = link;
      }
    }

    if (coverUrl == null && item['thumbnail'] != null) {
      final thumb = item['thumbnail'].toString();
      if (thumb.startsWith('http')) {
        coverUrl = thumb;
      }
    }

    final rawContent = (item['content'] as String? ?? item['description'] as String? ?? '');
    if (coverUrl == null) {
      final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(rawContent);
      if (imgMatch != null) {
        coverUrl = imgMatch.group(1);
      }
    }

    if (coverUrl == null || coverUrl.isEmpty) {
      coverUrl = defaultCover;
    }

    final title = _cleanText(item['title'] as String? ?? '');
    final description = _cleanText(item['description'] as String? ?? rawContent);

    final rawCategories = (item['categories'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        [];

    final author = (item['author'] as String? ?? sourceName).trim();
    final pubDate = item['pubDate'] as String? ?? '';
    final link = item['link'] as String? ?? sourceUrl;

    return ItNewsArticle(
      id: item['guid']?.toString() ?? '${title.hashCode}',
      title: title,
      description: description,
      url: link,
      coverImageUrl: coverUrl,
      publishedAt: pubDate,
      readingTimeMinutes: (description.length / 400).ceil().clamp(1, 10),
      tags: rawCategories.isNotEmpty ? rawCategories : [sourceName],
      reactions: 25 + (title.length % 50),
      authorName: author.isNotEmpty ? author : sourceName,
      authorAvatar: null,
      sourceName: sourceName,
      sourceBadge: sourceBadge,
      sourceUrl: sourceUrl,
    );
  }

  /// Hacker News Algolia JSON formatidan parsing
  factory ItNewsArticle.fromHnJson(Map<String, dynamic> hit) {
    final title = _cleanText(hit['title'] as String? ?? '');
    final storyUrl = hit['url'] as String? ?? 'https://news.ycombinator.com/item?id=${hit['objectID']}';
    final author = hit['author'] as String? ?? 'Hacker News';
    final points = hit['points'] as int? ?? 10;
    final createdAt = hit['created_at'] as String? ?? '';

    // Domain nomini aniqlash
    String domain = 'news.ycombinator.com';
    try {
      if (hit['url'] != null) {
        domain = Uri.parse(hit['url'].toString()).host;
      }
    } catch (_) {}

    return ItNewsArticle(
      id: hit['objectID']?.toString() ?? '${title.hashCode}',
      title: title,
      description: 'Rasmiy manba: $domain. Ushbu maqola Hacker News hamjamiyatida $points ta ovoz to\'pladi.',
      url: storyUrl,
      coverImageUrl: null,
      publishedAt: createdAt,
      readingTimeMinutes: 3,
      tags: ['Tech', domain],
      reactions: points,
      authorName: author,
      authorAvatar: null,
      sourceName: domain,
      sourceBadge: 'Hacker News Official',
      sourceUrl: storyUrl,
    );
  }

  /// Matndagi HTML teglarni va maxsus belgilarni tozalash
  static String _cleanText(String html) {
    if (html.isEmpty) return '';

    // 1. HTML teglarni olib tashlash
    var text = html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');

    // 2. HTML maxsus entity'larini almashtirish
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return text;
  }
}

// ─── IT yangiliklari kategoriyalari (tablar) ────────────────────────────────
enum ItNewsCategory {
  all,
  spotUz,
  kunUz,
  techCrunch,
  flutter,
  hackerNews,
  devTo,
}

extension ItNewsCategoryExt on ItNewsCategory {
  String get label => switch (this) {
        ItNewsCategory.all => 'Barchasi',
        ItNewsCategory.spotUz => 'Spot.uz IT',
        ItNewsCategory.kunUz => 'Kun.uz Texno',
        ItNewsCategory.techCrunch => 'TechCrunch',
        ItNewsCategory.flutter => 'Flutter & Google',
        ItNewsCategory.hackerNews => 'Hacker News',
        ItNewsCategory.devTo => 'Dev.to',
      };

  String get sourceName => switch (this) {
        ItNewsCategory.all => 'Rasmiy Manbalar',
        ItNewsCategory.spotUz => 'Spot.uz',
        ItNewsCategory.kunUz => 'Kun.uz',
        ItNewsCategory.techCrunch => 'TechCrunch',
        ItNewsCategory.flutter => 'Flutter Official',
        ItNewsCategory.hackerNews => 'Hacker News',
        ItNewsCategory.devTo => 'Dev.to',
      };
}
