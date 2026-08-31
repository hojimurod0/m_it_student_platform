import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/homework/data/models/homework_model.dart';

abstract class HomeworkRemoteDataSource {
  Future<List<HomeworkItemModel>> getHomeworkList();
  Future<HomeworkItemModel> submitHomework({
    required String homeworkId,
    String? text,
    String? githubUrl,
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  });
}

class HomeworkRemoteDataSourceImpl implements HomeworkRemoteDataSource {
  final ApiClient _apiClient;

  HomeworkRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<HomeworkItemModel>> getHomeworkList() async {
    try {
      final response = await _apiClient.get(AppConfig.portalStudentHomeworks);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['homeworks'] is List) {
        rawList = response['homeworks'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan vazifalar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => HomeworkItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Vazifalarni yuklashda aloqa xatosi', e);
    }
  }

  @override
  Future<HomeworkItemModel> submitHomework({
    required String homeworkId,
    String? text,
    String? githubUrl,
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final endpoint = AppConfig.portalStudentHomeworkSubmit(homeworkId);

      final fields = <String, String>{
        if (text != null && text.isNotEmpty) ...{
          'text': text,
          'answer': text,
          'content': text,
        },
        if (githubUrl != null && githubUrl.isNotEmpty) ...{
          'github_url': githubUrl,
          'link': githubUrl,
          'url': githubUrl,
        },
        if (comment != null && comment.isNotEmpty) ...{
          'comment': comment,
          'notes': comment,
        },
      };

      final files = <http.MultipartFile>[];
      if (filePath != null && filePath.isNotEmpty) {
        final f = File(filePath);
        if (await f.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'file',
            filePath,
            filename: fileName ?? f.uri.pathSegments.last,
          );
          files.add(multipartFile);
        }
      } else if (fileBytes != null && fileBytes.isNotEmpty) {
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName ?? 'homework_attachment.zip',
        );
        files.add(multipartFile);
      }

      dynamic response;
      if (files.isNotEmpty) {
        try {
          response = await _apiClient.postMultipart(
            endpoint,
            fields: fields,
            files: files,
          );
        } catch (_) {
          // Fallback to alternative LMS endpoint
          response = await _apiClient.postMultipart(
            '/lms/homeworks/$homeworkId/submit/',
            fields: fields,
            files: files,
          );
        }
      } else {
        // First try standard JSON payload
        final jsonPayload = <String, dynamic>{
          if (text != null && text.isNotEmpty) 'content': text,
          if (text != null && text.isNotEmpty) 'text': text,
          if (text != null && text.isNotEmpty) 'answer': text,
          if (githubUrl != null && githubUrl.isNotEmpty) 'link': githubUrl,
          if (githubUrl != null && githubUrl.isNotEmpty) 'github_url': githubUrl,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        };
        if (jsonPayload.isEmpty) jsonPayload['text'] = 'Topshirildi';

        try {
          response = await _apiClient.post(
            endpoint,
            body: jsonPayload,
          );
        } catch (e) {
          try {
            // Fallback 1: Try with FormData Multipart (even without files)
            response = await _apiClient.postMultipart(
              endpoint,
              fields: fields.isNotEmpty ? fields : {'text': 'Topshirildi', 'content': 'Topshirildi'},
            );
          } catch (_) {
            // Fallback 2: Try alternative LMS endpoint
            response = await _apiClient.post(
              '/lms/homeworks/$homeworkId/submit/',
              body: jsonPayload,
            );
          }
        }
      }

      if (response is Map<String, dynamic>) {
        return HomeworkItemModel.fromJson(response);
      }
      return HomeworkItemModel(
        id: homeworkId,
        title: 'Topshirilgan vazifa',
        course: 'M-IT Academy',
        deadline: 'Bugun',
        description: text ?? comment ?? '',
        status: HomeworkStatusModel.submitted,
        githubRepoUrl: githubUrl,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Vazifani topshirishda aloqa xatosi', e);
    }
  }
}
