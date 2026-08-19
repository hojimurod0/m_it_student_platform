/// Core failure types for Clean Architecture.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server bilan bog\'lanishda xatolik yuz berdi']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Internet aloqasi mavjud emas']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Avtorizatsiya xatosi']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Kesh ma\'lumotlarini o\'qishda xatolik']);
}

/// Generic Result type for operations that can either succeed with [T] or fail with [Failure].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        Error() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final f) => f,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      Error(failure: final f) => onFailure(f),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
