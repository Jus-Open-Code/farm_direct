import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/buyer_profile_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../domain/usecases/order_usecases.dart';

class CartItem {
  final String id;
  final ProductEntity product;
  double quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

class BuyerViewModel extends ChangeNotifier {
  final CreateBuyerProfileUseCase _createBuyerProfileUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final GetBuyerOrdersUseCase _getBuyerOrdersUseCase;

  BuyerViewModel({
    required CreateBuyerProfileUseCase createBuyerProfileUseCase,
    required GetAllProductsUseCase getAllProductsUseCase,
    required SearchProductsUseCase searchProductsUseCase,
    required GetProductsByCategoryUseCase getProductsByCategoryUseCase,
    required CreateOrderUseCase createOrderUseCase,
    required GetBuyerOrdersUseCase getBuyerOrdersUseCase,
  })  : _createBuyerProfileUseCase = createBuyerProfileUseCase,
        _getAllProductsUseCase = getAllProductsUseCase,
        _searchProductsUseCase = searchProductsUseCase,
        _getProductsByCategoryUseCase = getProductsByCategoryUseCase,
        _createOrderUseCase = createOrderUseCase,
        _getBuyerOrdersUseCase = getBuyerOrdersUseCase;

  List<ProductEntity> _products = [];
  List<OrderEntity> _orders = [];
  List<CartItem> _cartItems = [];
  List<ProductEntity> _wishlist = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<ProductEntity> get products => _products;
  List<OrderEntity> get orders => _orders;
  List<CartItem> get cartItems => _cartItems;
  List<ProductEntity> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Create Buyer Profile
  Future<bool> createProfile({
    required String id,
    required String name,
    required String phone,
    required String address,
    XFile? imageFile,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final profile = BuyerProfileEntity(
        id: id,
        name: name,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
      );

      await _createBuyerProfileUseCase(profile, imageFile);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Fetch Products
  Future<void> fetchProducts() async {
    _setLoading(true);
    _setError(null);
    try {
      _products = await _getAllProductsUseCase();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Search Products
  Future<void> searchProducts(String query) async {
    _setLoading(true);
    _setError(null);
    try {
      if (query.isEmpty) {
        _products = await _getAllProductsUseCase();
      } else {
        _products = await _searchProductsUseCase(query);
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Filter By Category
  Future<void> filterByCategory(String category) async {
    _setLoading(true);
    _setError(null);
    try {
      if (category == 'All') {
        _products = await _getAllProductsUseCase();
      } else {
        _products = await _getProductsByCategoryUseCase(category);
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // ==========================================
  // CART ACTIONS (using Supabase Realtime/DB)
  // ==========================================

  Future<void> fetchCart(String buyerId) async {
    try {
      final response = await Supabase.instance.client
          .from('cart')
          .select('*, products(*)')
          .eq('buyer_id', buyerId);

      _cartItems = (response as List).map((item) {
        final productMap = item['products'] as Map<String, dynamic>;
        final product = ProductEntity(
          id: productMap['id'] as String,
          farmerId: productMap['farmer_id'] as String,
          name: productMap['name'] as String,
          category: productMap['category'] as String,
          quantity: (productMap['quantity'] as num).toDouble(),
          unit: productMap['unit'] as String,
          price: (productMap['price'] as num).toDouble(),
          description: productMap['description'] as String?,
          imageUrl: productMap['image_url'] as String?,
          harvestDate: DateTime.parse(productMap['harvest_date'] as String),
          createdAt: DateTime.parse(productMap['created_at'] as String),
        );

        return CartItem(
          id: item['id'] as String,
          product: product,
          quantity: (item['quantity'] as num).toDouble(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addToCart(String buyerId, ProductEntity product, double quantity) async {
    try {
      final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        final newQuantity = _cartItems[existingIndex].quantity + quantity;
        await Supabase.instance.client
            .from('cart')
            .update({'quantity': newQuantity})
            .eq('buyer_id', buyerId)
            .eq('product_id', product.id);
      } else {
        await Supabase.instance.client.from('cart').insert({
          'buyer_id': buyerId,
          'product_id': product.id,
          'quantity': quantity,
        });
      }

      await fetchCart(buyerId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateCartQuantity(String buyerId, String productId, double quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(buyerId, productId);
        return;
      }

      await Supabase.instance.client
          .from('cart')
          .update({'quantity': quantity})
          .eq('buyer_id', buyerId)
          .eq('product_id', productId);

      await fetchCart(buyerId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> removeFromCart(String buyerId, String productId) async {
    try {
      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('buyer_id', buyerId)
          .eq('product_id', productId);

      await fetchCart(buyerId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ==========================================
  // WISHLIST ACTIONS (using Supabase DB)
  // ==========================================

  Future<void> fetchWishlist(String buyerId) async {
    try {
      final response = await Supabase.instance.client
          .from('wishlist')
          .select('*, products(*)')
          .eq('buyer_id', buyerId);

      _wishlist = (response as List).map((item) {
        final productMap = item['products'] as Map<String, dynamic>;
        return ProductEntity(
          id: productMap['id'] as String,
          farmerId: productMap['farmer_id'] as String,
          name: productMap['name'] as String,
          category: productMap['category'] as String,
          quantity: (productMap['quantity'] as num).toDouble(),
          unit: productMap['unit'] as String,
          price: (productMap['price'] as num).toDouble(),
          description: productMap['description'] as String?,
          imageUrl: productMap['image_url'] as String?,
          harvestDate: DateTime.parse(productMap['harvest_date'] as String),
          createdAt: DateTime.parse(productMap['created_at'] as String),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleWishlist(String buyerId, ProductEntity product) async {
    try {
      final isFav = _wishlist.any((item) => item.id == product.id);

      if (isFav) {
        await Supabase.instance.client
            .from('wishlist')
            .delete()
            .eq('buyer_id', buyerId)
            .eq('product_id', product.id);
      } else {
        await Supabase.instance.client.from('wishlist').insert({
          'buyer_id': buyerId,
          'product_id': product.id,
        });
      }

      await fetchWishlist(buyerId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  bool isFavorite(String productId) {
    return _wishlist.any((item) => item.id == productId);
  }

  // ==========================================
  // ORDERS / CHECKOUT
  // ==========================================

  Future<void> fetchOrders(String buyerId) async {
    _setLoading(true);
    try {
      _orders = await _getBuyerOrdersUseCase(buyerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> checkout(String buyerId, String buyerName) async {
    if (_cartItems.isEmpty) return false;
    _setLoading(true);
    _setError(null);
    try {
      final items = _cartItems.map((cartItem) {
        return OrderItemEntity(
          id: '',
          orderId: '',
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          price: cartItem.product.price,
        );
      }).toList();

      final order = OrderEntity(
        id: '',
        buyerId: buyerId,
        buyerName: buyerName,
        status: 'pending',
        totalAmount: cartTotal,
        items: items,
        createdAt: DateTime.now(),
      );

      // Create Order in Supabase
      await _createOrderUseCase(order);

      // Clear Cart in Supabase
      await Supabase.instance.client.from('cart').delete().eq('buyer_id', buyerId);

      _cartItems.clear();
      // Reload orders
      await fetchOrders(buyerId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
