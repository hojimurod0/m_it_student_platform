/// Ilovadagi ma'lumotlar qatlami (Data layer) xatoliklari
abstract class AppException implements Exception {
  final String message;
  final dynamic cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Server tomonidan 500, 502, 503 kabi xatoliklar qaytganda
class ServerException extends AppException {
  const ServerException([super.message = 'Serverda xatolik yuz berdi', super.cause]);
}

/// Internet ulanishi yo'q bo'lganda yoki SocketException
class NetworkException extends AppException {
  const NetworkException([super.message = 'Internet aloqasi mavjud emas', super.cause]);
}

/// 401 Unauthorized yoki Token eskirganda
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Avtorizatsiya muddati tugagan', super.cause]);
}

/// 403 Forbidden
class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Ushbu amalni bajarishga ruxsat yo\'q', super.cause]);
}

/// 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'So\'ralgan ma\'lumot topilmadi', super.cause]);
}

/// JSON deserializatsiyada ma'lumot formati buzilganda
class ParseException extends AppException {
  const ParseException([super.message = 'Ma\'lumotlarni o\'qishda xatolik', super.cause]);
}

/// Kesh bilan ishlashda xatolik yuz berganda
class CacheException extends AppException {
  const CacheException([super.message = 'Kesh ma\'lumotlari bilan ishlashda xatolik', super.cause]);
}
