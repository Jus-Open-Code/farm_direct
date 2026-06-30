class BuyerProfileEntity {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? profilePhoto;
  final DateTime createdAt;

  BuyerProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.profilePhoto,
    required this.createdAt,
  });
}
