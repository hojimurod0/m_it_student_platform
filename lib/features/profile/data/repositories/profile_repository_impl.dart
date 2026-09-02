import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/storage/secure_storage_service.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/domain/models/attendance_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/grade_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    ProfileRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  }) : _remoteDataSource =
           remoteDataSource ?? ProfileRemoteDataSourceImpl(apiClient: apiClient);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<StudentProfile> getStudentProfile() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return MockProfileRepository.currentStudent;
    }

    try {
      // Fetch all needed data in parallel — including progress API & homeworks
      final results = await Future.wait([
        _remoteDataSource.fetchProfile(),
        _remoteDataSource.fetchGroups().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchGrades().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchAttendance().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchProgress().catchError((_) => <String, dynamic>{}),
        _remoteDataSource.fetchHomeworks().catchError((_) => <dynamic>[]),
      ]);

      final data = Map<String, dynamic>.from(results[0] as Map<String, dynamic>);

      if (data['person'] is Map) {
        final p = data['person'] as Map;
        final fName = p['first_name']?.toString() ?? '';
        final lName = p['last_name']?.toString() ?? '';
        final fullName = '$fName $lName'.trim();
        data['fullName'] = fullName.isNotEmpty
            ? fullName
            : (data['full_name']?.toString() ?? data['name']?.toString() ?? 'Talaba');
        data['phone'] = p['phone_number']?.toString() ?? data['phone']?.toString() ?? '';
        data['id'] = (p['id'] ?? data['id'] ?? '').toString();
        data['avatarUrl'] = p['photo_url']?.toString() ?? data['avatar_url']?.toString() ?? '';
      } else {
        final fName = data['first_name']?.toString() ?? '';
        final lName = data['last_name']?.toString() ?? '';
        final fullName = '$fName $lName'.trim();
        data['fullName'] = fullName.isNotEmpty
            ? fullName
            : (data['full_name']?.toString() ?? data['name']?.toString() ?? 'Talaba');
        data['phone'] = data['phone_number']?.toString() ?? data['phone']?.toString() ?? '';
        data['id'] = (data['id'] ?? '').toString();
        data['avatarUrl'] = data['photo_url']?.toString() ?? data['avatar_url']?.toString() ?? '';
      }

      final rawGroups = results[1];
      Map<String, dynamic>? firstGroup;
      if (rawGroups is List && rawGroups.isNotEmpty && rawGroups.first is Map) {
        firstGroup = Map<String, dynamic>.from(rawGroups.first as Map);
      } else if (rawGroups is Map && rawGroups['results'] is List && (rawGroups['results'] as List).isNotEmpty) {
        final f = (rawGroups['results'] as List).first;
        if (f is Map) firstGroup = Map<String, dynamic>.from(f);
      } else if (rawGroups is Map && rawGroups['groups'] is List && (rawGroups['groups'] as List).isNotEmpty) {
        final f = (rawGroups['groups'] as List).first;
        if (f is Map) firstGroup = Map<String, dynamic>.from(f);
      } else if (rawGroups is Map && rawGroups['data'] is List && (rawGroups['data'] as List).isNotEmpty) {
        final f = (rawGroups['data'] as List).first;
        if (f is Map) firstGroup = Map<String, dynamic>.from(f);
      } else if (rawGroups is Map<String, dynamic>) {
        firstGroup = rawGroups;
      }
      if (firstGroup != null) {
        data['courseName'] = firstGroup['name']?.toString() ?? firstGroup['title']?.toString() ?? '';
        data['group'] = firstGroup['name']?.toString() ?? firstGroup['title']?.toString() ?? '';
        data['mentorName'] = firstGroup['teacher_name']?.toString() ?? firstGroup['mentor']?.toString() ?? '';
        final parsedRoom = resolveRoomString(
          firstGroup['room_name'] ??
              firstGroup['room'] ??
              firstGroup['classroom'] ??
              firstGroup['room_number'] ??
              firstGroup['auditorium'] ??
              data['room_name'] ??
              data['room'] ??
              data['classroom'],
          firstGroup,
        );
        data['room'] = parsedRoom.isNotEmpty ? parsedRoom : (firstGroup['room_name']?.toString() ?? 'Google xona');
        data['classDays'] = firstGroup['schedule_label']?.toString() ?? firstGroup['schedule']?.toString() ?? '';
        if (firstGroup['lesson_start'] != null && firstGroup['lesson_end'] != null) {
          data['classTime'] = "${firstGroup['lesson_start']} – ${firstGroup['lesson_end']}";
        }
        if (firstGroup['monthly_fee'] != null) {
          final digits = firstGroup['monthly_fee'].toString().replaceAll(RegExp(r'[^\d]'), '');
          final numVal = int.tryParse(digits);
          if (numVal != null) {
            final formatted = numVal.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]} ',
            );
            data['monthlyPayment'] = "$formatted so'm";
          }
        }
      }

      // ── 1. Calculate dynamic real Overall Score (O'zlashtirish) from live grades & evaluated homeworks ──
      final rawGrades = results[2];
      final rawHomeworks = results[5];
      final List<double> evaluatedScores = [];

      // Extract scores from /portal/student/my-grades/
      if (rawGrades is List) {
        for (final g in rawGrades) {
          if (g is Map) {
            final s = (g['score'] ?? g['grade'] ?? g['points'] ?? g['ball'] as num?)?.toDouble();
            final max = (g['max_score'] ?? g['total_score'] as num?)?.toDouble() ?? 100.0;
            if (s != null && s > 0) {
              evaluatedScores.add(max > 0 && max != 100.0 ? (s / max * 100.0) : s.clamp(0.0, 100.0));
            }
          }
        }
      } else if (rawGrades is Map) {
        if (rawGrades['average_score'] != null || rawGrades['gpa'] != null) {
          final avg = (rawGrades['average_score'] as num?)?.toDouble() ??
              (rawGrades['gpa'] as num?)?.toDouble();
          if (avg != null && avg > 0) evaluatedScores.add(avg.clamp(0.0, 100.0));
        }
      }

      // Extract scores from /portal/student/my-homeworks/
      List<dynamic> hwList = [];
      if (rawHomeworks is List) {
        hwList = rawHomeworks;
      } else if (rawHomeworks is Map) {
        if (rawHomeworks['homeworks'] is List) {
          hwList = rawHomeworks['homeworks'] as List;
        } else if (rawHomeworks['results'] is List) {
          hwList = rawHomeworks['results'] as List;
        } else if (rawHomeworks['data'] is List) {
          hwList = rawHomeworks['data'] as List;
        }
      }

      for (final hw in hwList) {
        if (hw is Map) {
          final mySub = hw['my_submission'];
          final s = (mySub is Map ? (mySub['score'] as num?)?.toDouble() : null) ??
              (hw['score'] as num?)?.toDouble();
          final max = (hw['max_score'] as num?)?.toDouble() ?? 100.0;
          if (s != null && s > 0) {
            evaluatedScores.add(max > 0 && max != 100.0 ? (s / max * 100.0) : s.clamp(0.0, 100.0));
          }
        }
      }

      if (evaluatedScores.isNotEmpty) {
        final avg = evaluatedScores.reduce((a, b) => a + b) / evaluatedScores.length;
        data['overallScore'] = avg.round().clamp(0, 100);
      }

      // ── 2. Calculate dynamic real Attendance Rate (Davomat) from live attendance ──
      final rawAtt = results[3];
      if (rawAtt is Map) {
        final pastLessons = (rawAtt['past_lessons_count'] as num?)?.toInt() ?? 0;
        final attendedCount = (rawAtt['attended_count'] as num?)?.toInt() ?? 0;
        final attPercent = (rawAtt['attendance_percentage'] as num?)?.toInt();

        if (attPercent != null && attPercent > 0) {
          data['attendancePercentage'] = attPercent.clamp(0, 100);
        } else if (pastLessons > 0) {
          data['attendancePercentage'] = ((attendedCount / pastLessons) * 100).round().clamp(0, 100);
        } else {
          // If no past lessons in current period, 100% clean attendance
          data['attendancePercentage'] = 100;
        }
      }

      // ── 3. Merge real progress API data (/portal/student/progress/) ──
      final rawProgress = results[4];
      if (rawProgress is Map<String, dynamic>) {
        if (rawProgress['coins'] != null) data['coins'] = (rawProgress['coins'] as num).toInt();
        if (rawProgress['shartnoma_tangalari'] != null) data['coins'] = (rawProgress['shartnoma_tangalari'] as num).toInt();
        if (rawProgress['homework_percent'] != null) data['homeworkPercent'] = (rawProgress['homework_percent'] as num).toInt();
        if (rawProgress['homework_percentage'] != null) data['homeworkPercent'] = (rawProgress['homework_percentage'] as num).toInt();
        if (rawProgress['overall_score'] != null && evaluatedScores.isEmpty) data['overallScore'] = (rawProgress['overall_score'] as num).toInt();
        if (rawProgress['attendance_percentage'] != null) data['attendancePercentage'] = (rawProgress['attendance_percentage'] as num).toInt();
        if (rawProgress['attendance_rate'] != null) data['attendancePercentage'] = (rawProgress['attendance_rate'] as num).toInt();
        if (rawProgress['overall_progress_percentage'] != null && evaluatedScores.isEmpty) data['overallScore'] = (rawProgress['overall_progress_percentage'] as num).toInt();
      }

      final profile = StudentProfile.fromJson(data);

      await AppCacheService.setCache(
        AppCacheService.keyProfile,
        data,
        ttl: const Duration(days: 1),
      );

      final savedUser = MockProfileRepository.currentStudent;
      final merged = profile.copyWith(
        avatarIndex: savedUser.avatarIndex,
        gender: savedUser.gender.isNotEmpty ? savedUser.gender : profile.gender,
        coins: profile.coins > 0 ? profile.coins : savedUser.coins,
        homeworkPercent: profile.homeworkPercent > 0
            ? profile.homeworkPercent
            : savedUser.homeworkPercent,
      );
      MockProfileRepository.setStudent(merged);
      return merged;
    } catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyProfile);
      if (cached is Map<String, dynamic>) {
        return StudentProfile.fromJson(cached);
      }
      rethrow;
    }
  }

  @override
  Future<StudentProfile> updateProfile({
    String? fullName,
    String? phone,
    String? parentName,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
  }) async {
    MockProfileRepository.updateProfile(
      fullName: fullName,
      phone: phone,
      parentName: parentName,
      parentPhone: parentPhone,
      email: email,
      gender: gender,
      avatarIndex: avatarIndex,
    );

    if (!AppConfig.useMockData) {
      try {
        final body = <String, dynamic>{
          if (fullName != null && fullName.trim().isNotEmpty) ...{
            'first_name': fullName.trim().contains(' ')
                ? fullName.trim().split(' ').first
                : fullName.trim(),
            'last_name': fullName.trim().contains(' ')
                ? fullName.trim().split(' ').sublist(1).join(' ')
                : '',
            'full_name': fullName.trim(),
            'name': fullName.trim(),
          },
          if (phone != null && phone.trim().isNotEmpty) ...{
            'phone': phone.trim(),
            'phone_number': phone.trim(),
          },
          if (parentName != null && parentName.trim().isNotEmpty) ...{
            'parent_name': parentName.trim(),
            'parents_name': parentName.trim(),
          },
          if (parentPhone != null && parentPhone.trim().isNotEmpty) ...{
            'parent_phone': parentPhone.trim(),
            'parents_phone': parentPhone.trim(),
          },
          if (email != null && email.trim().isNotEmpty) ...{'email': email.trim()},
          if (gender != null && gender.trim().isNotEmpty) ...{'gender': gender.trim()},
          if (avatarIndex != null) ...{'avatar_index': avatarIndex},
        };
        final res = await _remoteDataSource.updateProfile(body);
        if (res.isNotEmpty) {
          final updated = StudentProfile.fromJson(res);
          MockProfileRepository.updateProfile(
            fullName: updated.fullName.isNotEmpty ? updated.fullName : fullName,
            phone: updated.phone.isNotEmpty ? updated.phone : phone,
            parentName: updated.parentName.isNotEmpty ? updated.parentName : parentName,
            parentPhone: updated.parentPhone.isNotEmpty
                ? updated.parentPhone
                : parentPhone,
            email: updated.email.isNotEmpty ? updated.email : email,
            gender: gender,
            avatarIndex: avatarIndex,
          );
        }
      } catch (_) {
        // Local persistence continues
      }
    }

    return MockProfileRepository.currentStudent;
  }

  @override
  Future<List<GradeItem>> getStudentGrades() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return MockProfileRepository.grades;
    }

    try {
      final data = await _remoteDataSource.fetchGrades();
      List<GradeItem>? list;
      if (data is List) {
        list = data
            .map((j) => GradeItem.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['grades'] is List) {
        list = (data['grades'] as List)
            .map((j) => GradeItem.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['results'] is List) {
        list = (data['results'] as List)
            .map((j) => GradeItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      if (list != null && list.isNotEmpty) {
        await AppCacheService.setCache(AppCacheService.keyGrades, data, ttl: const Duration(hours: 4));
        return list;
      }
    } catch (_) {
      final cached = AppCacheService.getCache(AppCacheService.keyGrades);
      if (cached is List) {
        return cached.map((j) => GradeItem.fromJson(j as Map<String, dynamic>)).toList();
      } else if (cached is Map && cached['grades'] is List) {
        return (cached['grades'] as List).map((j) => GradeItem.fromJson(j as Map<String, dynamic>)).toList();
      }
      rethrow;
    }

    return const [];
  }

  @override
  Future<List<AttendanceRecord>> getStudentAttendance() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return MockProfileRepository.attendance;
    }

    try {
      final data = await _remoteDataSource.fetchAttendance();
      List<AttendanceRecord>? list;
      if (data is List && data.isNotEmpty) {
        list = data
            .map((j) => AttendanceRecord.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['results'] is List) {
        list = (data['results'] as List)
            .map((j) => AttendanceRecord.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['attendance'] is List) {
        list = (data['attendance'] as List)
            .map((j) => AttendanceRecord.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      if (list != null && list.isNotEmpty) {
        await AppCacheService.setCache(AppCacheService.keyAttendance, data, ttl: const Duration(hours: 4));
        return list;
      }
    } catch (_) {
      final cached = AppCacheService.getCache(AppCacheService.keyAttendance);
      if (cached is List) {
        return cached.map((j) => AttendanceRecord.fromJson(j as Map<String, dynamic>)).toList();
      } else if (cached is Map && cached['results'] is List) {
        return (cached['results'] as List).map((j) => AttendanceRecord.fromJson(j as Map<String, dynamic>)).toList();
      }
      rethrow;
    }

    return const [];
  }

  @override
  Future<void> deleteAccount({String password = '', String? reason}) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await AppCacheService.clearAll();
      await LocalStorageService.clearAuth();
      await SecureStorageService.clearAll();
      MockProfileRepository.reset();
      return;
    }

    try {
      await _remoteDataSource.deleteProfile(password: password, reason: reason);
    } catch (e) {
      if (e is NetworkException) rethrow;
    } finally {
      await AppCacheService.clearAll();
      await LocalStorageService.clearAuth();
      await SecureStorageService.clearAll();
      MockProfileRepository.reset();
    }
  }
}
