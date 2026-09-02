import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/features/home/data/datasources/home_remote_data_source.dart';
import 'package:m_it_student_platform/features/home/data/repositories/mock_home_repository.dart';
import 'package:m_it_student_platform/features/home/domain/models/announcement_model.dart';
import 'package:m_it_student_platform/features/home/domain/repositories/home_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    HomeRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  }) : _remoteDataSource =
           remoteDataSource ?? HomeRemoteDataSourceImpl(apiClient: apiClient);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Lesson> getFeaturedClass() async {
    // 1. Explicit Development-Only Mock Mode
    if (AppConfig.useMockData && AppConfig.environment == AppEnvironment.development) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return MockHomeRepository.featuredClass;
    }

    // 2. Production Network-First with Cache Fallback
    try {
      dynamic schedData;
      dynamic groupData;

      try {
        final results = await Future.wait([
          _remoteDataSource.fetchFeaturedClass(),
          _remoteDataSource.fetchGroups().catchError((_) => null),
        ]);
        schedData = results[0];
        groupData = results[1];
      } catch (_) {
        schedData = await _remoteDataSource.fetchFeaturedClass().catchError((_) => null);
        groupData = await _remoteDataSource.fetchGroups().catchError((_) => null);
      }

      final mergedMap = <String, dynamic>{};

      if (groupData != null) {
        Map<String, dynamic>? firstGroup;
        if (groupData is List && groupData.isNotEmpty && groupData.first is Map) {
          firstGroup = Map<String, dynamic>.from(groupData.first as Map);
        } else if (groupData is Map && groupData['results'] is List && (groupData['results'] as List).isNotEmpty) {
          final f = (groupData['results'] as List).first;
          if (f is Map) firstGroup = Map<String, dynamic>.from(f);
        } else if (groupData is Map && groupData['groups'] is List && (groupData['groups'] as List).isNotEmpty) {
          final f = (groupData['groups'] as List).first;
          if (f is Map) firstGroup = Map<String, dynamic>.from(f);
        } else if (groupData is Map && groupData['data'] is List && (groupData['data'] as List).isNotEmpty) {
          final f = (groupData['data'] as List).first;
          if (f is Map) firstGroup = Map<String, dynamic>.from(f);
        } else if (groupData is Map<String, dynamic>) {
          firstGroup = groupData;
        }

        if (firstGroup != null) {
          mergedMap.addAll(firstGroup);
          if (firstGroup['room_name'] != null && firstGroup['room_name'].toString().isNotEmpty) {
            mergedMap['room'] = firstGroup['room_name'];
          }
          if (firstGroup['group'] is Map) {
            final grp = Map<String, dynamic>.from(firstGroup['group'] as Map);
            mergedMap.addAll(grp);
            if (grp['room_name'] != null && grp['room_name'].toString().isNotEmpty) {
              mergedMap['room'] = grp['room_name'];
            }
          }
        }
      }

      if (schedData != null) {
        if (schedData is Map<String, dynamic>) {
          if (schedData['group'] is Map) {
            final grp = Map<String, dynamic>.from(schedData['group'] as Map);
            for (final e in grp.entries) {
              if (e.value != null && e.value.toString().isNotEmpty) {
                mergedMap[e.key] = e.value;
              }
            }
          }
          for (final e in schedData.entries) {
            if (e.key != 'schedule' && e.value != null && e.value.toString().isNotEmpty) {
              mergedMap[e.key] = e.value;
            }
          }

          if (schedData['schedule'] is List) {
            final sched = schedData['schedule'] as List;
            final list = sched.whereType<Map<String, dynamic>>().toList();
            final currentWeekday = DateTime.now().weekday;
            final activeLesson = list.firstWhere(
              (s) => (s['is_today'] == true || s['weekday_index'] == currentWeekday || s['weekday'] == currentWeekday) && s['is_lesson'] == true,
              orElse: () => list.firstWhere(
                (s) => s['is_lesson'] == true,
                orElse: () => list.isNotEmpty ? list.first : <String, dynamic>{},
              ),
            );
            if (activeLesson.isNotEmpty) {
              for (final e in activeLesson.entries) {
                if (e.value != null && e.value.toString().isNotEmpty) {
                  mergedMap[e.key] = e.value;
                }
              }
            }
          }
        } else if (schedData is List && schedData.isNotEmpty && schedData.first is Map) {
          final sMap = Map<String, dynamic>.from(schedData.first as Map);
          for (final e in sMap.entries) {
            if (e.value != null && e.value.toString().isNotEmpty) {
              mergedMap[e.key] = e.value;
            }
          }
        }
      }

      if (mergedMap.isNotEmpty) {
        final lesson = Lesson.fromJson(mergedMap);
        await AppCacheService.setCache(
          AppCacheService.keyFeaturedClass,
          mergedMap,
          ttl: const Duration(hours: 6),
        );
        return lesson;
      }
    } catch (e) {
      // 3. Try reading from offline cache
      final cached = AppCacheService.getCache(AppCacheService.keyFeaturedClass);
      if (cached != null) {
        if (cached is List && cached.isNotEmpty) {
          return Lesson.fromJson(cached.first as Map<String, dynamic>);
        } else if (cached is Map<String, dynamic>) {
          return Lesson.fromJson(cached);
        }
      }
    }

    return MockHomeRepository.featuredClass;
  }

  @override
  Future<List<Announcement>> getAnnouncements() async {
    // 1. Production Network-First with Cache Fallback
    try {
      final data = await _remoteDataSource.fetchAnnouncements();
      List<Announcement>? list;
      if (data is List) {
        list = data
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['announcements'] is List) {
        list = (data['announcements'] as List)
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (list != null) {
        await AppCacheService.setCache(
          AppCacheService.keyAnnouncements,
          data,
          ttl: const Duration(hours: 12),
        );
        return list;
      }
    } catch (e) {
      // 2. Try reading from offline cache
      final cached = AppCacheService.getCache(AppCacheService.keyAnnouncements);
      if (cached != null) {
        if (cached is List) {
          return cached
              .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (cached is Map && cached['announcements'] is List) {
          return (cached['announcements'] as List)
              .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }

  @override
  Future<Announcement> getAnnouncementDetails(String id) async {
    try {
      final data = await _remoteDataSource.fetchAnnouncementDetails(id);
      if (data is Map<String, dynamic>) {
        return Announcement.fromJson(data);
      }
    } catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyAnnouncements);
      if (cached is List) {
        final found = cached
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .where((a) => a.id == id);
        if (found.isNotEmpty) return found.first;
      }
      throw Exception("Ma'lumot topilmadi va tarmoq xatosi yuz berdi");
    }
    throw Exception('Kutilmagan xatolik yuz berdi');
  }
}
