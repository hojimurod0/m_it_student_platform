/// Domain va Presentation qatlamlariga uzatiladigan biznes xatoliklari (Failure)
abstract class Failure {
  final String message;
  final dynamic cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode ^ runtimeType.hashCode;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Serverda nosozlik yuz berdi', super.cause]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Internet aloqasi yo\'q. Ulanishni tekshiring', super.cause]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Iltimos, qaytadan tizimga kiring', super.cause]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Sizda bu amal uchun yetarli huquq yo\'q', super.cause]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ma\'lumot topilmadi', super.cause]);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Kutilmagan server javob formati', super.cause]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Keshdan ma\'lumot olishda xatolik', super.cause]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Noma\'lum xatolik yuz berdi', super.cause]);
}
