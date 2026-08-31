abstract class AuthEvent {
  const AuthEvent();
}

/// Ilova ochilganda mavjud sessiyani (token, user) tekshirish
class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

/// Login formasini topshirish
class AuthLoginSubmittedEvent extends AuthEvent {
  const AuthLoginSubmittedEvent({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;
}

/// Tizimdan chiqish (Logout)
class AuthLogoutRequestedEvent extends AuthEvent {
  const AuthLogoutRequestedEvent();
}
