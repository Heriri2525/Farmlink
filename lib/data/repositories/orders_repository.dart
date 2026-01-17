import 'package:farmlink/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersRepository {
  final SupabaseClient _supabaseClient;

  OrdersRepository(this._supabaseClient);

  Stream<List<Order>> getBuyingOrders(String userId) {
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', userId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map(Order.fromJson).toList());
  }

  Stream<List<Order>> getSellingOrders(String userId) {
    return _supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('seller_id', userId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map(Order.fromJson).toList());
  }

  Future<void> createOrder({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String productName,
    required double totalPrice,
    required double quantity,
  }) async {
    await _supabaseClient.from('orders').insert({
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'product_name': productName,
      'total_price': totalPrice,
      'quantity': quantity,
      'status': OrderStatus.pending.toJson(),
      'user_id': buyerId,
    });
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(Supabase.instance.client);
});

final buyingOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getBuyingOrders(userId);
});

final sellingOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getSellingOrders(userId);
});
