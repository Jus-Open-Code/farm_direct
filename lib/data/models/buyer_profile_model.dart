import '../../domain/entities/buyer_profile_entity.dart';

class BuyerProfileModel extends BuyerProfileEntity {
  BuyerProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    super.profilePhoto,
    required super.createdAt,
  });

  factory BuyerProfileModel.fromJson(Map<String, dynamic> json) {
    return BuyerProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'profile_photo': profilePhoto,
    };
  }
}
