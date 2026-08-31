import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final UserModel user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Unauthenticated;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.errorMessage);
  final String errorMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure &&
          runtimeType == other.runtimeType &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => errorMessage.hashCode;
}
