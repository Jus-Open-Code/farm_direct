class FarmerProfileEntity {
  final String id;
  final String farmerId; // Format: FARM000001
  final String name;
  final String phone;
  final String village;
  final String district;
  final String state;
  final String pincode;
  final double farmSize;
  final List<String> products; // Types of crops grown
  final String? profilePhoto;
  final DateTime createdAt;

  FarmerProfileEntity({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.phone,
    required this.village,
    required this.district,
    required this.state,
    required this.pincode,
    required this.farmSize,
    required this.products,
    this.profilePhoto,
    required this.createdAt,
  });
}
