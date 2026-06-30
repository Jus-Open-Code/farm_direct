import 'package:image_picker/image_picker.dart';
import '../entities/farmer_profile_entity.dart';
import '../entities/buyer_profile_entity.dart';

abstract class ProfileRepository {
  Future<FarmerProfileEntity?> getFarmerProfile(String id);

  Future<BuyerProfileEntity?> getBuyerProfile(String id);

  Future<void> createFarmerProfile({
    required FarmerProfileEntity profile,
    XFile? imageFile,
  });

  Future<void> createBuyerProfile({
    required BuyerProfileEntity profile,
    XFile? imageFile,
  });
}
