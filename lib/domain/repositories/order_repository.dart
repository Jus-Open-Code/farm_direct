import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> createOrder({
    required OrderEntity order,
  });

  Future<List<OrderEntity>> getBuyerOrders(String buyerId);

  Future<List<OrderEntity>> getFarmerOrders(String farmerId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
