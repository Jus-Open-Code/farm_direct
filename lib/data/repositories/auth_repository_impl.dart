import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await dataSource.updateUserRole(userId: userId, role: role);
    } catch (e) {
      rethrow;
    }
  }
}
