class OrderItemEntity {
  final String id;
  final String orderId;
  final String productId;
  final String productName; // denormalized or joined for UI ease
  final double quantity;
  final double price;

  OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class OrderEntity {
  final String id;
  final String buyerId;
  final String buyerName; // joined for Farmer view convenience
  final String status; // 'pending', 'processing', 'completed', 'cancelled'
  final double totalAmount;
  final List<OrderItemEntity> items;
  final DateTime createdAt;

  OrderEntity({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
  });
}
