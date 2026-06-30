import 'package:image_picker/image_picker.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/supabase_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseRemoteDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      return await dataSource.getAllProducts();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> getFarmerProducts(String farmerId) async {
    try {
      return await dataSource.getFarmerProducts(farmerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createProduct({
    required ProductEntity product,
    XFile? imageFile,
  }) async {
    try {
      final model = ProductModel(
        id: product.id,
        farmerId: product.farmerId,
        name: product.name,
        category: product.category,
        quantity: product.quantity,
        unit: product.unit,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        harvestDate: product.harvestDate,
        createdAt: product.createdAt,
      );

      await dataSource.createProduct(product: model, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProduct({
    required ProductEntity product,
    XFile? imageFile,
  }) async {
    try {
      final model = ProductModel(
        id: product.id,
        farmerId: product.farmerId,
        name: product.name,
        category: product.category,
        quantity: product.quantity,
        unit: product.unit,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        harvestDate: product.harvestDate,
        createdAt: product.createdAt,
      );

      await dataSource.updateProduct(product: model, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await dataSource.deleteProduct(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      return await dataSource.searchProducts(query);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      return await dataSource.getProductsByCategory(category);
    } catch (e) {
      rethrow;
    }
  }
}
