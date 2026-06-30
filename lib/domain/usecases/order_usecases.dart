import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);

  Future<void> call(OrderEntity order) {
    return repository.createOrder(order: order);
  }
}

class GetBuyerOrdersUseCase {
  final OrderRepository repository;
  GetBuyerOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(String buyerId) {
    return repository.getBuyerOrders(buyerId);
  }
}

class GetFarmerOrdersUseCase {
  final OrderRepository repository;
  GetFarmerOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(String farmerId) {
    return repository.getFarmerOrders(farmerId);
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  Future<void> call(String orderId, String status) {
    return repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
