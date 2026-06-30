import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.farmerId,
    required super.name,
    required super.category,
    required super.quantity,
    required super.unit,
    required super.price,
    super.description,
    super.imageUrl,
    required super.harvestDate,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      farmerId: json['farmer_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farmer_id': farmerId,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'harvest_date': harvestDate.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}
