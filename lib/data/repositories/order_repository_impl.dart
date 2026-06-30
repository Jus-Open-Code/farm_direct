import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/supabase_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseRemoteDataSource dataSource;

  OrderRepositoryImpl(this.dataSource);

  @override
  Future<void> createOrder({
    required OrderEntity order,
  }) async {
    try {
      final itemModels = order.items.map((item) {
        return OrderItemModel(
          id: item.id,
          orderId: item.orderId,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          price: item.price,
        );
      }).toList();

      final model = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        buyerName: order.buyerName,
        status: order.status,
        totalAmount: order.totalAmount,
        items: itemModels,
        createdAt: order.createdAt,
      );

      await dataSource.createOrder(order: model);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderEntity>> getBuyerOrders(String buyerId) async {
    try {
      return await dataSource.getBuyerOrders(buyerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderEntity>> getFarmerOrders(String farmerId) async {
    try {
      return await dataSource.getFarmerOrders(farmerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await dataSource.updateOrderStatus(orderId: orderId, status: status);
    } catch (e) {
      rethrow;
    }
  }
}
