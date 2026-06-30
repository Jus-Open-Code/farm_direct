import 'package:image_picker/image_picker.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetAllProductsUseCase {
  final ProductRepository repository;
  GetAllProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() {
    return repository.getAllProducts();
  }
}

class GetFarmerProductsUseCase {
  final ProductRepository repository;
  GetFarmerProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(String farmerId) {
    return repository.getFarmerProducts(farmerId);
  }
}

class CreateProductUseCase {
  final ProductRepository repository;
  CreateProductUseCase(this.repository);

  Future<void> call(ProductEntity product, XFile? imageFile) {
    return repository.createProduct(product: product, imageFile: imageFile);
  }
}

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product, XFile? imageFile) {
    return repository.updateProduct(product: product, imageFile: imageFile);
  }
}

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteProduct(id);
  }
}

class SearchProductsUseCase {
  final ProductRepository repository;
  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(String query) {
    return repository.searchProducts(query);
  }
}

class GetProductsByCategoryUseCase {
  final ProductRepository repository;
  GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call(String category) {
    return repository.getProductsByCategory(category);
  }
}
