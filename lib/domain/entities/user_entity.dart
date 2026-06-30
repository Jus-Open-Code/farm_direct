class UserEntity {
  final String id;
  final String email;
  final String? role; // 'farmer', 'buyer', or null (if not selected yet)
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    this.role,
    required this.createdAt,
  });
}
