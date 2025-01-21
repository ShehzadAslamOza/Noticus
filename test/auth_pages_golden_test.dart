import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:noticus/features/auth/bloc/auth_bloc.dart';
import 'package:noticus/features/auth/domain/entities/user.dart';
import 'package:noticus/features/auth/domain/repositories/auth_repository.dart';
import 'package:noticus/features/auth/domain/usecases/login_usecase.dart';
import 'package:noticus/features/auth/domain/usecases/signup_usecase.dart';
import 'package:noticus/features/auth/presentation/login_page.dart';
import 'package:noticus/features/auth/presentation/signup_page.dart';

void main() {
  group('Auth Pages Golden Tests', () {
    // LoginPage Tests
    testGoldens('LoginPage initial state', (WidgetTester tester) async {
      await loadAppFonts();

      final widget = BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: MockLoginUseCase(),
          signupUseCase: MockSignupUseCase(),
        ),
        child: MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'login_page_initial');
    });

    testGoldens('LoginPage with error state', (WidgetTester tester) async {
      await loadAppFonts();

      final widget = BlocProvider<AuthBloc>(
        create: (_) {
          final bloc = AuthBloc(
            loginUseCase: MockLoginUseCase(),
            signupUseCase: MockSignupUseCase(),
          );
          bloc.emit(AuthFailure('Invalid credentials'));
          return bloc;
        },
        child: MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'login_page_error');
    });

    // SignupPage Tests
    testGoldens('SignupPage initial state', (WidgetTester tester) async {
      await loadAppFonts();

      final widget = BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: MockLoginUseCase(),
          signupUseCase: MockSignupUseCase(),
        ),
        child: MaterialApp(
          home: SignupPage(),
        ),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'signup_page_initial');
    });

    testGoldens('SignupPage with error state', (WidgetTester tester) async {
      await loadAppFonts();

      final widget = BlocProvider<AuthBloc>(
        create: (_) {
          final bloc = AuthBloc(
            loginUseCase: MockLoginUseCase(),
            signupUseCase: MockSignupUseCase(),
          );
          bloc.emit(AuthFailure('Failed to create account'));
          return bloc;
        },
        child: MaterialApp(
          home: SignupPage(),
        ),
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'signup_page_error');
    });
  });
}

// Mocks for dependencies
class MockLoginUseCase extends LoginUseCase {
  MockLoginUseCase() : super(MockAuthRepository());

  @override
  Future<UserEntity> call(String email, String password) async {
    return UserEntity(id: '1', email: email);
  }
}

class MockSignupUseCase extends SignupUseCase {
  MockSignupUseCase() : super(MockAuthRepository());

  @override
  Future<UserEntity> call(String email, String password) async {
    return UserEntity(id: '1', email: email);
  }
}

class MockAuthRepository extends AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    return UserEntity(id: '1', email: email);
  }

  @override
  Future<UserEntity> signup(String email, String password) async {
    return UserEntity(id: '1', email: email);
  }
}
