import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m_it_student_platform/features/home/domain/models/it_news_model.dart';

class ItNewsRepository {
  ItNewsRepository._();

  static final ItNewsRepository instance = ItNewsRepository._();

  // Kesh
  final Map<ItNewsCategory, List<ItNewsArticle>> _cache = {};
  final Map<ItNewsCategory, DateTime> _cacheTime = {};
  static const Duration _cacheDuration = Duration(minutes: 15);

  /// Asosiy fetch metodi
  Future<List<ItNewsArticle>> fetchArticles(ItNewsCategory category) async {
    final cached = _cache[category];
    final cachedAt = _cacheTime[category];
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration) {
      return cached;
    }

    try {
      List<ItNewsArticle> articles = [];

      switch (category) {
        case ItNewsCategory.all:
          articles = await _fetchAllCurated();
          break;
        case ItNewsCategory.spotUz:
          articles = await _fetchSpotUz();
          break;
        case ItNewsCategory.kunUz:
          articles = await _fetchKunUz();
          break;
        case ItNewsCategory.techCrunch:
          articles = await _fetchTechCrunch();
          break;
        case ItNewsCategory.flutter:
          articles = await _fetchFlutterMedium();
          break;
        case ItNewsCategory.hackerNews:
          articles = await _fetchHackerNews();
          break;
        case ItNewsCategory.devTo:
          articles = await _fetchDevTo();
          break;
      }

      if (articles.isNotEmpty) {
        _cache[category] = articles;
        _cacheTime[category] = DateTime.now();
        return articles;
      }
    } catch (_) {}

    // Fallback: Agar tarmoq xatosi bo'lsa, zaxira rasmiy ma'lumotlarni qaytaramiz
    return _getFallbackArticles(category);
  }

  /// 1. Barcha rasmiy manbalardan aralash (Spot.uz, TechCrunch, Flutter, Dev.to)
  Future<List<ItNewsArticle>> _fetchAllCurated() async {
    final futures = await Future.wait([
      _fetchSpotUz(),
      _fetchTechCrunch(),
      _fetchFlutterMedium(),
      _fetchDevTo(),
    ]);

    final List<ItNewsArticle> combined = [];
    final spotList = futures[0];
    final tcList = futures[1];
    final flutterList = futures[2];
    final devList = futures[3];

    // Har bir manbadan teng miqdorda olib aralashtiramiz
    final maxLen = [spotList.length, tcList.length, flutterList.length, devList.length]
        .reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLen; i++) {
      if (i < spotList.length) combined.add(spotList[i]);
      if (i < tcList.length) combined.add(tcList[i]);
      if (i < flutterList.length) combined.add(flutterList[i]);
      if (i < devList.length) combined.add(devList[i]);
    }

    return combined.take(20).toList();
  }

  /// 2. Spot.uz IT & Biznes rasmiy yangiliklari
  Future<List<ItNewsArticle>> _fetchSpotUz() async {
    final url = Uri.parse(
        'https://api.rss2json.com/v1/api.json?rss_url=https://www.spot.uz/oz/rss/');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final items = jsonMap['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        return ItNewsArticle.fromRssJson(
          item as Map<String, dynamic>,
          sourceName: 'Spot.uz',
          sourceBadge: 'Rasmiy O\'zbekiston',
          sourceUrl: 'https://www.spot.uz',
          defaultCover: 'https://www.spot.uz/media/img/2024/02/43nD0f17078058263353_b.jpg',
        );
      }).toList();
    }
    return [];
  }

  /// 3. Kun.uz Texnologiya & Jamiyat rasmiy yangiliklari
  Future<List<ItNewsArticle>> _fetchKunUz() async {
    final url = Uri.parse(
        'https://api.rss2json.com/v1/api.json?rss_url=https://kun.uz/news/rss');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final items = jsonMap['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        return ItNewsArticle.fromRssJson(
          item as Map<String, dynamic>,
          sourceName: 'Kun.uz',
          sourceBadge: 'Rasmiy Portal',
          sourceUrl: 'https://kun.uz',
        );
      }).toList();
    }
    return [];
  }

  /// 4. TechCrunch jahon rasmiy IT & Startap nashri
  Future<List<ItNewsArticle>> _fetchTechCrunch() async {
    final url = Uri.parse(
        'https://api.rss2json.com/v1/api.json?rss_url=https://techcrunch.com/feed/');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final items = jsonMap['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        return ItNewsArticle.fromRssJson(
          item as Map<String, dynamic>,
          sourceName: 'TechCrunch',
          sourceBadge: 'Global Tech & VC',
          sourceUrl: 'https://techcrunch.com',
          defaultCover: 'https://techcrunch.com/wp-content/uploads/2015/02/cropped-cropped-favicon-gradient.png',
        );
      }).toList();
    }
    return [];
  }

  /// 5. Flutter & Google Developers Official Blog
  Future<List<ItNewsArticle>> _fetchFlutterMedium() async {
    final url = Uri.parse(
        'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/flutter');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final items = jsonMap['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        return ItNewsArticle.fromRssJson(
          item as Map<String, dynamic>,
          sourceName: 'Flutter Official',
          sourceBadge: 'Google & Flutter',
          sourceUrl: 'https://blog.flutter.dev',
          defaultCover: 'https://cdn-images-1.medium.com/proxy/1*TGH72Nnw24QL3iV9IOm4VA.png',
        );
      }).toList();
    }
    return [];
  }

  /// 6. Hacker News (Y Combinator) Algolia API
  Future<List<ItNewsArticle>> _fetchHackerNews() async {
    final url = Uri.parse(
        'https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=18');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final hits = jsonMap['hits'] as List<dynamic>? ?? [];

      return hits.map((hit) {
        return ItNewsArticle.fromHnJson(hit as Map<String, dynamic>);
      }).toList();
    }
    return [];
  }

  /// 7. Dev.to Community API
  Future<List<ItNewsArticle>> _fetchDevTo() async {
    final url = Uri.parse('https://dev.to/api/articles?per_page=15&state=rising');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'M-IT-Student-App/1.0',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          json.decode(response.body) as List<dynamic>;

      return jsonList
          .map((j) => ItNewsArticle.fromJson(j as Map<String, dynamic>))
          .where((a) => a.title.isNotEmpty && a.title.length > 5)
          .toList();
    }
    return [];
  }

  void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  /// Offline yoki tarmoq xatosi bo'lganda ishonchli zaxira ma'lumotlari
  List<ItNewsArticle> _getFallbackArticles(ItNewsCategory category) {
    const fallbackData = [
      ItNewsArticle(
        id: 'fb-spot-1',
        title: 'O\'zbekistonning Cerberus startapi TechCrunch Startup Battlefield tanlovida g\'olib bo\'ldi',
        description: 'Kiberxavfsizlik sohasidagi O\'zbekiston loyihasi 50 ming dollar mukofot va San-Frantsiskodagi jahon finaliga yo\'llanmani qo\'lga kiritdi.',
        url: 'https://www.spot.uz/oz/2026/08/13/cerberus-startup/',
        coverImageUrl: 'https://www.spot.uz/media/img/2026/08/qce4udr62j4laOVwaK117866282884335_b.webp',
        publishedAt: '2026-08-13 14:35:00',
        readingTimeMinutes: 3,
        tags: ['Startap', 'Kiberxavfsizlik', 'Spot.uz'],
        reactions: 142,
        authorName: 'Spot.uz Tahririyati',
        authorAvatar: null,
        sourceName: 'Spot.uz',
        sourceBadge: 'Rasmiy O\'zbekiston',
        sourceUrl: 'https://www.spot.uz',
      ),
      ItNewsArticle(
        id: 'fb-flutter-1',
        title: 'Google & Flutter: Vibe once, run anywhere with Antigravity and Flutter',
        description: 'Google Antigravity va Flutter yordamida zamonaviy cross-platform mobil va veb ilovalarni avtomatlashtirilgan holda yaratish imkoniyatlari.',
        url: 'https://blog.flutter.dev/vibe-once-run-anywhere-with-antigravity-and-flutter-25af06e60a91',
        coverImageUrl: 'https://cdn-images-1.medium.com/max/1024/1*Mg2Bj5FBg1I19r1Jw4q9Kg.png',
        publishedAt: '2026-06-29 16:01:00',
        readingTimeMinutes: 5,
        tags: ['Flutter', 'Google AI', 'Mobile'],
        reactions: 320,
        authorName: 'Craig Labenz (Google Flutter)',
        authorAvatar: null,
        sourceName: 'Flutter Official',
        sourceBadge: 'Google & Flutter',
        sourceUrl: 'https://blog.flutter.dev',
      ),
      ItNewsArticle(
        id: 'fb-tc-1',
        title: 'OpenAI-backed Thrive Holdings raises \$2B to bring AI to enterprise',
        description: 'Sun\'iy intellekt texnologiyalarini yirik korporativ bizneslarga tatbiq etish uchun yangi 2 milliard dollarlik venchur investitsiya jalb qilindi.',
        url: 'https://techcrunch.com/2026/08/12/openai-backed-thrive-holdings-raises-2b-to-bring-ai-to-the-enterprise/',
        coverImageUrl: 'https://techcrunch.com/wp-content/uploads/2015/02/cropped-cropped-favicon-gradient.png',
        publishedAt: '2026-08-12 17:41:29',
        readingTimeMinutes: 4,
        tags: ['AI', 'Enterprise', 'TechCrunch'],
        reactions: 98,
        authorName: 'Rebecca Bellan',
        authorAvatar: null,
        sourceName: 'TechCrunch',
        sourceBadge: 'Global Tech & VC',
        sourceUrl: 'https://techcrunch.com',
      ),
      ItNewsArticle(
        id: 'fb-kun-1',
        title: 'Raqamli O\'zbekiston: IT eksport hajmi 1 milliard dollarga yetkazilishi rejalashtirilmoqda',
        description: 'O\'zbekiston IT Park rezidentlari soni ortib, mahalliy dasturchilar tomonidan yaratilgan dasturiy ta\'minotlar jahon bozoriga eksport qilinmoqda.',
        url: 'https://kun.uz/news/category/tehnologiya',
        coverImageUrl: null,
        publishedAt: '2026-08-13 12:00:00',
        readingTimeMinutes: 3,
        tags: ['IT Park', 'Raqamli O\'zbekiston'],
        reactions: 85,
        authorName: 'Kun.uz IT Bo\'limi',
        authorAvatar: null,
        sourceName: 'Kun.uz',
        sourceBadge: 'Rasmiy Portal',
        sourceUrl: 'https://kun.uz',
      ),
    ];

    if (category == ItNewsCategory.spotUz) {
      return [fallbackData[0]];
    } else if (category == ItNewsCategory.flutter) {
      return [fallbackData[1]];
    } else if (category == ItNewsCategory.techCrunch) {
      return [fallbackData[2]];
    } else if (category == ItNewsCategory.kunUz) {
      return [fallbackData[3]];
    }

    return fallbackData;
  }
}
