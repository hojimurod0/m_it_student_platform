import 'package:m_it_student_platform/core/error/failures.dart';

/// Funksional dasturlash (Either / Result) modeli:
/// Natija yo [Success] yoki [FailureResult] bo'ladi.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        FailureResult() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        FailureResult(failure: final f) => f,
      };

  /// Pattern matching orqali holatni boshqarish
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success(data: final d) => success(d),
        FailureResult(failure: final f) => failure(f),
      };

  /// Muvaqqaiyatli natijani qayta ishlash
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(data: final d) => Success(transform(d)),
        FailureResult(failure: final f) => FailureResult(f),
      };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  String toString() => 'FailureResult(failure: $failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FailureResult<T> && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
