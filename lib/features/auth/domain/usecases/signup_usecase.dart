import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signup(email, password);
  }
}
