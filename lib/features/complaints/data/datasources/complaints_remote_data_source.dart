import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class ComplaintsRemoteDataSource {
  Future<void> submitComplaint({
    required String subject,
    required String body,
    int? targetPersonId,
  });
  Future<dynamic> getComplaints();
}

class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  ComplaintsRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<void> submitComplaint({
    required String subject,
    required String body,
    int? targetPersonId,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'content': body,
      'body': body,
      'text': body,
      'message': body,
    };
    if (targetPersonId != null) {
      payload['target_person_id'] = targetPersonId;
    }

    await _apiClient.post(
      AppConfig.portalStudentComplaints,
      body: payload,
    );
  }

  @override
  Future<dynamic> getComplaints() async {
    return await _apiClient.get(AppConfig.portalStudentComplaints);
  }
}
