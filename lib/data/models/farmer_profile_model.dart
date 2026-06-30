import '../../domain/entities/farmer_profile_entity.dart';

class FarmerProfileModel extends FarmerProfileEntity {
  FarmerProfileModel({
    required super.id,
    required super.farmerId,
    required super.name,
    required super.phone,
    required super.village,
    required super.district,
    required super.state,
    required super.pincode,
    required super.farmSize,
    required super.products,
    super.profilePhoto,
    required super.createdAt,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['id'] as String,
      farmerId: json['farmer_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      village: json['village'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      farmSize: (json['farm_size'] as num).toDouble(),
      products: List<String>.from(json['products'] ?? []),
      profilePhoto: json['profile_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'village': village,
      'district': district,
      'state': state,
      'pincode': pincode,
      'farm_size': farmSize,
      'products': products,
      'profile_photo': profilePhoto,
    };
  }
}
