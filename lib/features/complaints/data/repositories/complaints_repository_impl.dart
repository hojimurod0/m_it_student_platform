import 'package:m_it_student_platform/features/complaints/data/datasources/complaints_remote_data_source.dart';

abstract class ComplaintsRepository {
  Future<void> submitComplaint({
    required String subject,
    required String body,
    int? targetPersonId,
  });
  Future<dynamic> getComplaints();
}

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  ComplaintsRepositoryImpl({ComplaintsRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ComplaintsRemoteDataSourceImpl();

  final ComplaintsRemoteDataSource _dataSource;

  @override
  Future<void> submitComplaint({
    required String subject,
    required String body,
    int? targetPersonId,
  }) =>
      _dataSource.submitComplaint(
        subject: subject,
        body: body,
        targetPersonId: targetPersonId,
      );

  @override
  Future<dynamic> getComplaints() => _dataSource.getComplaints();
}
