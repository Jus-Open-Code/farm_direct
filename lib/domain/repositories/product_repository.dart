import 'package:image_picker/image_picker.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAllProducts();

  Future<List<ProductEntity>> getFarmerProducts(String farmerId);

  Future<void> createProduct({
    required ProductEntity product,
    XFile? imageFile,
  });

  Future<void> updateProduct({
    required ProductEntity product,
    XFile? imageFile,
  });

  Future<void> deleteProduct(String id);

  Future<List<ProductEntity>> searchProducts(String query);

  Future<List<ProductEntity>> getProductsByCategory(String category);
}
