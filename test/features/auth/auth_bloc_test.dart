import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  const tUser = UserModel(
    userId: '1',
    name: 'Test Student',
    phone: '+998901234567',
    role: UserRole.student,
    token: 'valid_jwt_token',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc Unit Tests', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(authRepository: mockAuthRepository);
      expect(bloc.state, equals(const AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when session is successfully restored',
      build: () {
        when(() => mockAuthRepository.restoreSession())
            .thenAnswer((_) async => tUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckStatusEvent()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.restoreSession()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when session restore returns null',
      build: () {
        when(() => mockAuthRepository.restoreSession())
            .thenAnswer((_) async => null);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckStatusEvent()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful login submission',
      build: () {
        when(
          () => mockAuthRepository.login(
            phone: '+998901234567',
            password: 'password123',
          ),
        ).thenAnswer((_) async => tUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginSubmittedEvent(
          phone: '+998901234567',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails with error',
      build: () {
        when(
          () => mockAuthRepository.login(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Parol noto\'g\'ri'));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginSubmittedEvent(
          phone: '+998901234567',
          password: 'wrong_password',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Exception: Parol noto\'g\'ri'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on logout request',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequestedEvent()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
