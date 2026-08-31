import 'package:flutter/foundation.dart';
import 'package:m_it_student_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser ?? _authRepository.currentUser;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(
        phone: phone,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Login yoki parol noto\'g\'ri';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
