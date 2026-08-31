import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';
import 'package:m_it_student_platform/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/repositories/lessons_repository.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  LessonsRepositoryImpl({
    LessonsRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  }) : _remoteDataSource =
           remoteDataSource ?? LessonsRemoteDataSourceImpl(apiClient: apiClient);

  final LessonsRemoteDataSource _remoteDataSource;

  @override
  Future<List<StudentGroup>> getStudentGroups() async {

    try {
      final data = await _remoteDataSource.fetchStudentGroups();
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'] as List;
      } else if (data is Map && data['groups'] is List) {
        items = data['groups'] as List;
      } else if (data is Map && data['schedule'] is List) {
        items = data['schedule'] as List;
      } else if (data is Map<String, dynamic>) {
        items = [data];
      }

      if (items.isNotEmpty) {
        final seen = <String>{};
        final groups = <StudentGroup>[];
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            final grp = StudentGroup.fromJson(item);
            final key = grp.code.isNotEmpty ? grp.code : grp.name;
            if (!seen.contains(key)) {
              seen.add(key);
              groups.add(grp);
            }
          }
        }
        if (groups.isNotEmpty) {
          await AppCacheService.setCache(
            AppCacheService.keyGroups,
            items,
            ttl: const Duration(hours: 12),
          );
          return groups;
        }
      }
    } catch (e) {
      AppLogger.warning('Talaba guruhlarini yuklashda ogohlantirish: $e', tag: 'LESSONS_REPO');
      final cached = AppCacheService.getCache(AppCacheService.keyGroups);
      if (cached is List) {
        return cached.whereType<Map<String, dynamic>>().map(StudentGroup.fromJson).toList();
      }
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }

  @override
  Future<List<Lesson>> getTodayLessons() async {
    try {
      final data = await _remoteDataSource.fetchTodayLessons();
      List<Lesson>? lessons;
      if (data is Map && data['schedule'] is List) {
        final sched = data['schedule'] as List;
        final list = sched.whereType<Map<String, dynamic>>().toList();
        final rootRoom = data['room'] ?? data['room_name'] ?? data['classroom'] ?? data['auditorium'];
        if (rootRoom != null && rootRoom.toString().isNotEmpty) {
          for (final s in list) {
            if (s['room'] == null || s['room'].toString().isEmpty) {
              s['room'] = rootRoom;
            }
          }
        }
        final currentWeekday = DateTime.now().weekday; // 1 = Monday, ..., 7 = Sunday

        // Match today's lesson: is_today == true OR matching current weekday
        final todayItems = list.where((s) {
          final isTodayFlag = s['is_today'] == true;
          final isWeekdayMatch = (s['weekday_index'] == currentWeekday ||
              s['weekday_number'] == currentWeekday ||
              s['weekday'] == currentWeekday);
          final hasLesson = s['is_lesson'] == true || s['has_lesson'] == true;
          return (isTodayFlag || isWeekdayMatch) && hasLesson;
        }).toList();

        if (todayItems.isNotEmpty) {
          lessons = todayItems.map((s) => Lesson.fromJson(s)).toList();
        } else {
          // If today has no lesson, return scheduled active lesson days
          final activeDays = list.where((s) => s['is_lesson'] == true).toList();
          if (activeDays.isNotEmpty) {
            lessons = activeDays.map((s) => Lesson.fromJson(s)).toList();
          } else if (list.isNotEmpty) {
            lessons = list.map((s) => Lesson.fromJson(s)).toList();
          } else {
            lessons = MockLessonsRepository.todayLessons;
          }
        }
      } else if (data is List) {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final list = data.whereType<Map<String, dynamic>>().toList();
        final todayItems = list.where((json) {
          final d = json['date']?.toString();
          return json['is_today'] == true || (d != null && d.startsWith(todayStr));
        }).toList();

        if (todayItems.isNotEmpty) {
          lessons = todayItems.map((json) => Lesson.fromJson(json)).toList();
        } else if (list.isNotEmpty) {
          lessons = list.map((json) => Lesson.fromJson(json)).toList();
        }
      } else if (data is Map && (data['results'] is List || data['lessons'] is List)) {
        final rawList = ((data['results'] ?? data['lessons']) as List)
            .whereType<Map<String, dynamic>>()
            .toList();
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final todayItems = rawList.where((json) {
          final d = json['date']?.toString();
          return json['is_today'] == true || (d != null && d.startsWith(todayStr));
        }).toList();
        if (todayItems.isNotEmpty) {
          lessons = todayItems.map((json) => Lesson.fromJson(json)).toList();
        } else {
          lessons = rawList.map((json) => Lesson.fromJson(json)).toList();
        }
      }

      if (lessons != null && lessons.isNotEmpty) {
        await AppCacheService.setCache(
          AppCacheService.keyLessons,
          data,
          ttl: const Duration(hours: 4),
        );
        return lessons;
      }
    } catch (e) {
      AppLogger.warning('Bugungi darslarni yuklashda xatolik: $e', tag: 'LESSONS_REPO');
      final cached = AppCacheService.getCache(AppCacheService.keyLessons);
      if (cached is List) {
        return cached
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (cached is Map && cached['results'] is List) {
        return (cached['results'] as List)
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
    return MockLessonsRepository.todayLessons;
  }

  @override
  Future<List<Lesson>> getTomorrowLessons() async {

    try {
      final data = await _remoteDataSource.fetchAllLessons();
      if (data is List) {
        return data
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyLessons);
      if (cached is List) {
        return cached
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }

  @override
  Future<List<Lesson>> getCompletedLessons() async {

    try {
      final data = await _remoteDataSource.fetchAllLessons();
      if (data is List) {
        return data
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }

  @override
  Future<Lesson> getLessonDetails(String lessonId) async {

    try {
      final data = await _remoteDataSource.fetchLessonDetails(lessonId);
      if (data is Map<String, dynamic>) {
        return Lesson.fromJson(data);
      }
    } catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyLessons);
      if (cached is List) {
        final found = cached
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .where((l) => l.id == lessonId);
        if (found.isNotEmpty) return found.first;
      }
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }

  @override
  Future<List<TopicModel>> getLessonTopics() async {
    try {
      final data = await _remoteDataSource.fetchAllLessons();
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'] as List;
      } else if (data is Map && data['lessons'] is List) {
        items = data['lessons'] as List;
      } else if (data is Map && data['data'] is List) {
        items = data['data'] as List;
      }

      if (items.isNotEmpty) {
        final topics = items
            .map((item) {
              if (item is Map) {
                return TopicModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            })
            .whereType<TopicModel>()
            .toList();
        if (topics.isNotEmpty) return topics;
      }
    } catch (e) {
      AppLogger.warning('Darslar ro\'yxatini olishda xatolik: $e', tag: 'MY_LESSONS');
    }
    return MockLessonsRepository.topics;
  }
}
