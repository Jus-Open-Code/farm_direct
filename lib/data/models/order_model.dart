import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Supposing there is a joined products table or productName is direct/joined.
    final productMap = json['products'] as Map<String, dynamic>?;
    final productName = productMap != null ? (productMap['name'] as String? ?? 'Product') : 'Product';

    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: productName,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.buyerId,
    required super.buyerName,
    required super.status,
    required super.totalAmount,
    required super.items,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse buyer name if joined
    final buyerMap = json['buyer_profiles'] as Map<String, dynamic>?;
    final buyerName = buyerMap != null ? (buyerMap['name'] as String? ?? 'Buyer') : 'Buyer';

    final itemsRaw = json['order_items'] as List<dynamic>? ?? [];
    final items = itemsRaw.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList();

    return OrderModel(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      buyerName: buyerName,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: items,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyer_id': buyerId,
      'status': status,
      'total_amount': totalAmount,
    };
  }
}
