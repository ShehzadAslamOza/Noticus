import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService firebaseAuthService;

  AuthRepositoryImpl({required this.firebaseAuthService});

  @override
  Future<UserEntity> login(String email, String password) async {
    final User user = await firebaseAuthService.login(email, password);
    return UserEntity(id: user.uid, email: user.email!);
  }

  @override
  Future<UserEntity> signup(String email, String password) async {
    final User user = await firebaseAuthService.signup(email, password);
    return UserEntity(id: user.uid, email: user.email!);
  }
}
