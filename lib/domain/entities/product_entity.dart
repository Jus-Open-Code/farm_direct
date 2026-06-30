class ProductEntity {
  final String id;
  final String farmerId;
  final String name;
  final String category;
  final double quantity;
  final String unit; // kg, quintal, ton, etc.
  final double price;
  final String? description;
  final String? imageUrl;
  final DateTime harvestDate;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    this.description,
    this.imageUrl,
    required this.harvestDate,
    required this.createdAt,
  });
}
