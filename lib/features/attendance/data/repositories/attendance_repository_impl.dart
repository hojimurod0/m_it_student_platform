import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';
import 'package:m_it_student_platform/features/attendance/domain/repositories/attendance_repository.dart';

export 'package:m_it_student_platform/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _dataSource;

  AttendanceRepositoryImpl({required AttendanceRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<AttendanceRecord>>> getMyAttendance() async {
    try {
      final models = await _dataSource.getMyAttendance();
      return Success(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.cause));
    } on UnauthorizedException catch (e) {
      return FailureResult(UnauthorizedFailure(e.message, e.cause));
    } on ForbiddenException catch (e) {
      return FailureResult(ForbiddenFailure(e.message, e.cause));
    } on NotFoundException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.cause));
    } on ParseException catch (e) {
      return FailureResult(ParseFailure(e.message, e.cause));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.cause));
    } catch (e) {
      return FailureResult(UnknownFailure('Davomatni olishda kutilmagan xatolik', e));
    }
  }
}
