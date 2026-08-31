import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/payments/data/models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<PaymentSummaryModel> getPaymentSummary();
  Future<List<PaymentTransactionModel>> getTransactions();
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final ApiClient _apiClient;

  PaymentsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PaymentSummaryModel> getPaymentSummary() async {
    try {
      final results = await Future.wait([
        _apiClient.get(AppConfig.portalStudentPayments),
        _apiClient.get(AppConfig.portalStudentGroups).catchError((_) => null),
      ]);
      final response = results[0];
      final groupsResponse = results[1];

      double groupMonthlyFee = 0.0;
      String? groupNameFromGroup;
      if (groupsResponse is List && groupsResponse.isNotEmpty && groupsResponse.first is Map) {
        final g = groupsResponse.first as Map;
        groupMonthlyFee = _parseAmount(g['monthly_fee'] ?? g['monthly_rate'] ?? g['price']);
        groupNameFromGroup = g['name']?.toString();
      } else if (groupsResponse is Map && groupsResponse['results'] is List && (groupsResponse['results'] as List).isNotEmpty) {
        final g = (groupsResponse['results'] as List).first;
        if (g is Map) {
          groupMonthlyFee = _parseAmount(g['monthly_fee'] ?? g['monthly_rate'] ?? g['price']);
          groupNameFromGroup = g['name']?.toString();
        }
      }

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['payments'] is List) {
        rawList = response['payments'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else if (response is Map<String, dynamic> && response.containsKey('monthly_rate')) {
        return PaymentSummaryModel.fromJson(response);
      }

      if (rawList.isNotEmpty) {
        double totalPaidSum = 0.0;
        double totalContractSum = 0.0;
        double monthlyFee = groupMonthlyFee > 0 ? groupMonthlyFee : 0.0;
        int paidCount = 0;

        for (final item in rawList) {
          if (item is Map) {
            final itemAmount = _parseAmount(item['amount'] ??
                item['price'] ??
                item['monthly_fee'] ??
                item['monthly_rate'] ??
                item['fee']);
            totalContractSum += itemAmount;
            if (monthlyFee == 0 && itemAmount > 0) {
              monthlyFee = itemAmount;
            }
            final isItemPaid = item['status'] == 'paid' ||
                item['status'] == 'completed' ||
                item['status_label'] == 'To\'langan';
            if (isItemPaid) {
              totalPaidSum += itemAmount;
              paidCount++;
            }
          }
        }

        if (monthlyFee == 0) monthlyFee = 500000.0;
        if (totalContractSum == 0) totalContractSum = monthlyFee;

        final unpaidList = rawList.where((item) {
          if (item is! Map) return false;
          final st = item['status']?.toString().toLowerCase();
          return st == 'unpaid' || st == 'pending' || st == 'to\'lanmagan';
        }).toList();

        final activeItem = unpaidList.isNotEmpty
            ? Map<String, dynamic>.from(unpaidList.first as Map)
            : Map<String, dynamic>.from(rawList.first as Map);

        final isPaid = unpaidList.isEmpty &&
            (activeItem['status'] == 'paid' ||
                activeItem['status'] == 'completed' ||
                activeItem['status_label'] == 'To\'langan');

        final monthName = activeItem['month_name']?.toString() ?? 'Avgust';
        final year = activeItem['year']?.toString() ?? '2026';
        final groupName = groupNameFromGroup ?? activeItem['group_name']?.toString() ?? 'Back end 05';

        final remaining = (totalContractSum - totalPaidSum).clamp(0.0, double.infinity);

        return PaymentSummaryModel(
          monthlyRate: monthlyFee,
          isPaid: isPaid,
          currentMonth: '$monthName oyi ($year)',
          nextDueDate: '1-Sentyabr, $year',
          daysUntilDue: 18,
          courseName: groupName,
          totalContract: totalContractSum,
          amountPaid: totalPaidSum,
          amountRemaining: remaining,
          paidMonths: paidCount,
          totalMonths: rawList.length,
          academicYear: activeItem['branch_name']?.toString() ?? 'M-IT Academy',
          semester: activeItem['payment_type_label']?.toString() ?? 'Oylik to\'lov',
        );
      } else if (response is List && response.isEmpty) {
        return const PaymentSummaryModel();
      }
      throw const ParseException('Kutilmagan to\'lov ma\'lumotlar formati');
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('To\'lov ma\'lumotlarini yuklashda aloqa xatosi', e);
    }
  }

  @override
  Future<List<PaymentTransactionModel>> getTransactions() async {
    try {
      final response = await _apiClient.get(AppConfig.portalStudentPayments);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['transactions'] is List) {
        rawList = response['transactions'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan tranzaksiyalar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => PaymentTransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Tranzaksiyalarni yuklashda aloqa xatosi', e);
    }
  }
}

double _parseAmount(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) {
    final clean = val.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
  return 0.0;
}
