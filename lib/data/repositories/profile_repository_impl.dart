import 'package:image_picker/image_picker.dart';
import '../../domain/entities/farmer_profile_entity.dart';
import '../../domain/entities/buyer_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/supabase_remote_datasource.dart';
import '../models/farmer_profile_model.dart';
import '../models/buyer_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseRemoteDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<FarmerProfileEntity?> getFarmerProfile(String id) async {
    try {
      return await dataSource.getFarmerProfile(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BuyerProfileEntity?> getBuyerProfile(String id) async {
    try {
      return await dataSource.getBuyerProfile(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createFarmerProfile({
    required FarmerProfileEntity profile,
    XFile? imageFile,
  }) async {
    try {
      final model = FarmerProfileModel(
        id: profile.id,
        farmerId: profile.farmerId,
        name: profile.name,
        phone: profile.phone,
        village: profile.village,
        district: profile.district,
        state: profile.state,
        pincode: profile.pincode,
        farmSize: profile.farmSize,
        products: profile.products,
        profilePhoto: profile.profilePhoto,
        createdAt: profile.createdAt,
      );

      await dataSource.createFarmerProfile(profile: model, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createBuyerProfile({
    required BuyerProfileEntity profile,
    XFile? imageFile,
  }) async {
    try {
      final model = BuyerProfileModel(
        id: profile.id,
        name: profile.name,
        phone: profile.phone,
        address: profile.address,
        profilePhoto: profile.profilePhoto,
        createdAt: profile.createdAt,
      );

      await dataSource.createBuyerProfile(profile: model, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }
}
