import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
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
      // Fetch all needed data in parallel — including progress API
      final results = await Future.wait([
        _remoteDataSource.fetchProfile(),
        _remoteDataSource.fetchGroups().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchGrades().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchAttendance().catchError((_) => <dynamic>[]),
        _remoteDataSource.fetchProgress().catchError((_) => <String, dynamic>{}),
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
      }
      if (firstGroup != null) {
        data['courseName'] = firstGroup['name']?.toString() ?? firstGroup['title']?.toString() ?? '';
        data['group'] = firstGroup['name']?.toString() ?? firstGroup['title']?.toString() ?? '';
        data['mentorName'] = firstGroup['teacher_name']?.toString() ?? firstGroup['mentor']?.toString() ?? '';
        final parsedRoom = resolveRoomString(
          firstGroup['room'] ??
              firstGroup['room_name'] ??
              firstGroup['classroom'] ??
              firstGroup['room_number'] ??
              firstGroup['auditorium'],
          firstGroup,
        );
        data['room'] = parsedRoom.isNotEmpty ? parsedRoom : '3-xona';
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

      // ── 1. Calculate dynamic real Overall Score (O'zlashtirish) from live grades ──
      final rawGrades = results[2];
      List<dynamic> gradeItems = [];
      if (rawGrades is List) {
        gradeItems = rawGrades;
      } else if (rawGrades is Map) {
        if (rawGrades['results'] is List) {
          gradeItems = rawGrades['results'] as List;
        } else if (rawGrades['grades'] is List) {
          gradeItems = rawGrades['grades'] as List;
        } else if (rawGrades['data'] is List) {
          gradeItems = rawGrades['data'] as List;
        } else if (rawGrades['average_score'] != null || rawGrades['gpa'] != null) {
          final avg = (rawGrades['average_score'] as num?)?.toInt() ??
              (rawGrades['gpa'] as num?)?.toInt();
          if (avg != null) data['overallScore'] = avg;
        }
      }

      if (gradeItems.isNotEmpty) {
        double totalScorePercent = 0;
        int gradedCount = 0;

        for (final g in gradeItems) {
          if (g is Map) {
            final score = (g['score'] as num?)?.toDouble() ??
                (g['grade'] as num?)?.toDouble() ??
                (g['points'] as num?)?.toDouble() ??
                (g['ball'] as num?)?.toDouble();
            final maxScore = (g['max_score'] as num?)?.toDouble() ??
                (g['total_score'] as num?)?.toDouble() ??
                100.0;

            if (score != null) {
              if (maxScore > 0 && maxScore != 100.0) {
                totalScorePercent += (score / maxScore) * 100.0;
              } else {
                totalScorePercent += score.clamp(0.0, 100.0);
              }
              gradedCount++;
            }
          }
        }

        if (gradedCount > 0) {
          data['overallScore'] = (totalScorePercent / gradedCount).round().clamp(0, 100);
        }
      }

      // ── 2. Calculate dynamic real Attendance Rate (Davomat) from live attendance ──
      final rawAtt = results[3];
      List<dynamic> attItems = [];
      if (rawAtt is List) {
        attItems = rawAtt;
      } else if (rawAtt is Map) {
        if (rawAtt['percentage'] != null || rawAtt['attendance_percentage'] != null || rawAtt['rate'] != null) {
          final p = (rawAtt['percentage'] as num?)?.toInt() ??
              (rawAtt['attendance_percentage'] as num?)?.toInt() ??
              (rawAtt['rate'] as num?)?.toInt();
          if (p != null) data['attendancePercentage'] = p;
        }

        if (rawAtt['results'] is List) {
          attItems = rawAtt['results'] as List;
        } else if (rawAtt['attendance'] is List) {
          attItems = rawAtt['attendance'] as List;
        } else if (rawAtt['records'] is List) {
          attItems = rawAtt['records'] as List;
        } else if (rawAtt['days'] is List) {
          attItems = rawAtt['days'] as List;
        }
      }

      if (attItems.isNotEmpty) {
        int attendedDaysCount = 0;
        int totalDaysCount = attItems.length;

        for (final a in attItems) {
          if (a is Map) {
            final status = (a['status'] ?? a['attendance_status'] ?? a['note'] ?? '').toString().toLowerCase();
            final isPresent = a['is_present'] == true ||
                a['attended'] == true ||
                a['present'] == true ||
                status.contains('present') ||
                status.contains('attended') ||
                status.contains('kelgan') ||
                status.contains('bor') ||
                status.contains('ha') ||
                (a['checkin'] != null && a['checkin'].toString().isNotEmpty && !status.contains('absent') && !status.contains('kelmagan'));

            if (isPresent) {
              attendedDaysCount++;
            }
          }
        }

        if (totalDaysCount > 0) {
          data['attendancePercentage'] = ((attendedDaysCount / totalDaysCount) * 100).round().clamp(0, 100);
        }
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
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
  }) async {
    MockProfileRepository.updateProfile(
      fullName: fullName,
      phone: phone,
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
}
