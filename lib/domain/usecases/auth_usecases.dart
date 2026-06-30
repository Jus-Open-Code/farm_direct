import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) {
    return repository.signIn(email: email, password: password);
  }
}

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) {
    return repository.signUp(email: email, password: password);
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

class UpdateUserRoleUseCase {
  final AuthRepository repository;
  UpdateUserRoleUseCase(this.repository);

  Future<void> call(String userId, String role) {
    return repository.updateUserRole(userId: userId, role: role);
  }
}
