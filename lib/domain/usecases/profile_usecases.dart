import 'package:image_picker/image_picker.dart';
import '../entities/farmer_profile_entity.dart';
import '../entities/buyer_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetFarmerProfileUseCase {
  final ProfileRepository repository;
  GetFarmerProfileUseCase(this.repository);

  Future<FarmerProfileEntity?> call(String id) {
    return repository.getFarmerProfile(id);
  }
}

class GetBuyerProfileUseCase {
  final ProfileRepository repository;
  GetBuyerProfileUseCase(this.repository);

  Future<BuyerProfileEntity?> call(String id) {
    return repository.getBuyerProfile(id);
  }
}

class CreateFarmerProfileUseCase {
  final ProfileRepository repository;
  CreateFarmerProfileUseCase(this.repository);

  Future<void> call(FarmerProfileEntity profile, XFile? imageFile) {
    return repository.createFarmerProfile(profile: profile, imageFile: imageFile);
  }
}

class CreateBuyerProfileUseCase {
  final ProfileRepository repository;
  CreateBuyerProfileUseCase(this.repository);

  Future<void> call(BuyerProfileEntity profile, XFile? imageFile) {
    return repository.createBuyerProfile(profile: profile, imageFile: imageFile);
  }
}
