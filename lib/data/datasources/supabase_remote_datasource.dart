import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/farmer_profile_model.dart';
import '../models/buyer_profile_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/market_rate_model.dart';

class SupabaseRemoteDataSource {
  final SupabaseClient _client;

  SupabaseRemoteDataSource(this._client);

  // Helper for Uploading files as binary bytes (Full PWA + Native Web compatible)
  Future<String> _uploadFile({
    required String bucket,
    required String path,
    required XFile file,
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = file.name.split('.').last;
    final String contentType = 'image/$extension';

    await _client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );

    // Get public URL
    final String publicUrl = _client.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        role: null,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Fetch public user role
      final userData = await _client
          .from('users')
          .select('role')
          .eq('id', response.user!.id)
          .maybeSingle();

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        role: userData != null ? userData['role'] as String? : null,
        createdAt: DateTime.parse(response.user!.createdAt),
      );
    }
    return null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null || session.user == null) return null;

    final user = session.user;
    final userData = await _client
        .from('users')
        .select('role, created_at')
        .eq('id', user.id)
        .maybeSingle();

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      role: userData != null ? userData['role'] as String? : null,
      createdAt: userData != null
          ? DateTime.parse(userData['created_at'] as String)
          : DateTime.now(),
    );
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    await _client.from('users').update({'role': role}).eq('id', userId);
  }

  // ==========================================
  // PROFILES
  // ==========================================

  Future<FarmerProfileModel?> getFarmerProfile(String id) async {
    final data = await _client
        .from('farmer_profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return FarmerProfileModel.fromJson(data);
  }

  Future<BuyerProfileModel?> getBuyerProfile(String id) async {
    final data = await _client
        .from('buyer_profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return BuyerProfileModel.fromJson(data);
  }

  Future<void> createFarmerProfile({
    required FarmerProfileModel profile,
    XFile? imageFile,
  }) async {
    String? imageUrl = profile.profilePhoto;

    if (imageFile != null) {
      final String path = 'profiles/${profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await _uploadFile(
        bucket: 'farmer_photos',
        path: path,
        file: imageFile,
      );
    }

    final Map<String, dynamic> data = profile.toJson();
    data['profile_photo'] = imageUrl;

    // Use upsert to support update
    await _client.from('farmer_profiles').upsert(data);
  }

  Future<void> createBuyerProfile({
    required BuyerProfileModel profile,
    XFile? imageFile,
  }) async {
    String? imageUrl = profile.profilePhoto;

    if (imageFile != null) {
      final String path = 'profiles/${profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await _uploadFile(
        bucket: 'buyer_photos',
        path: path,
        file: imageFile,
      );
    }

    final Map<String, dynamic> data = profile.toJson();
    data['profile_photo'] = imageUrl;

    await _client.from('buyer_profiles').upsert(data);
  }

  // ==========================================
  // PRODUCTS
  // ==========================================

  Future<List<ProductModel>> getAllProducts() async {
    final data = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getFarmerProducts(String farmerId) async {
    final data = await _client
        .from('products')
        .select()
        .eq('farmer_id', farmerId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createProduct({
    required ProductModel product,
    XFile? imageFile,
  }) async {
    String? imageUrl = product.imageUrl;

    if (imageFile != null) {
      final String path = 'products/${product.farmerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await _uploadFile(
        bucket: 'product_photos',
        path: path,
        file: imageFile,
      );
    }

    final Map<String, dynamic> data = product.toJson();
    data['image_url'] = imageUrl;

    await _client.from('products').insert(data);
  }

  Future<void> updateProduct({
    required ProductModel product,
    XFile? imageFile,
  }) async {
    String? imageUrl = product.imageUrl;

    if (imageFile != null) {
      final String path = 'products/${product.farmerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await _uploadFile(
        bucket: 'product_photos',
        path: path,
        file: imageFile,
      );
    }

    final Map<String, dynamic> data = product.toJson();
    data['image_url'] = imageUrl;

    await _client.from('products').update(data).eq('id', product.id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final data = await _client
        .from('products')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==========================================
  // ORDERS
  // ==========================================

  Future<void> createOrder({
    required OrderModel order,
  }) async {
    // 1. Insert order
    final orderResponse = await _client.from('orders').insert({
      'buyer_id': order.buyerId,
      'status': order.status,
      'total_amount': order.totalAmount,
    }).select('id').single();

    final orderId = orderResponse['id'] as String;

    // 2. Insert order items
    final List<Map<String, dynamic>> itemsData = order.items.map((item) {
      return {
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
      };
    }).toList();

    await _client.from('order_items').insert(itemsData);
  }

  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    final data = await _client
        .from('orders')
        .select('*, buyer_profiles(*), order_items(*, products(name))')
        .eq('buyer_id', buyerId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>> getFarmerOrders(String farmerId) async {
    // Select orders where at least one item belongs to the farmer's products
    final data = await _client
        .from('orders')
        .select('*, buyer_profiles(*), order_items(*, products(*))')
        .order('created_at', ascending: false);

    // Filter order items locally to only show what belongs to the farmer
    final allOrders = (data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Only keep orders containing farmer's products, and filter those order's item list
    final filteredOrders = <OrderModel>[];
    for (var o in allOrders) {
      final farmerItems = o.items.where((item) {
        // Look up item product detail inside the json
        final match = (data.firstWhere((element) => element['id'] == o.id)['order_items'] as List)
            .firstWhere((oi) => oi['id'] == item.id);
        final productDetails = match['products'] as Map<String, dynamic>?;
        return productDetails != null && productDetails['farmer_id'] == farmerId;
      }).toList();

      if (farmerItems.isNotEmpty) {
        filteredOrders.add(
          OrderModel(
            id: o.id,
            buyerId: o.buyerId,
            buyerName: o.buyerName,
            status: o.status,
            totalAmount: farmerItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
            items: farmerItems,
            createdAt: o.createdAt,
          ),
        );
      }
    }

    return filteredOrders;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
  }

  // ==========================================
  // MARKET RATES
  // ==========================================

  Future<List<MarketRateModel>> getDailyMarketRates({
    String? search,
    String? state,
    String? district,
  }) async {
    var query = _client.from('market_rates').select();

    if (search != null && search.isNotEmpty) {
      query = query.ilike('crop_name', '%$search%');
    }
    if (state != null && state.isNotEmpty) {
      query = query.eq('state', state);
    }
    if (district != null && district.isNotEmpty) {
      query = query.eq('district', district);
    }

    final data = await query.order('date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => MarketRateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MarketRateModel>> getTrendingCrops() async {
    // Simple mock crop trend for demo based on market rates order
    final data = await _client
        .from('market_rates')
        .select()
        .limit(4);

    return (data as List<dynamic>)
        .map((e) => MarketRateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
