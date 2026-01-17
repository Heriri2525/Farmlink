import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmlink/data/models/order_model.dart';
import 'package:farmlink/data/repositories/orders_repository.dart';

final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

// Primary provider
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(Supabase.instance.client);
});

// Restore singular name for backward compatibility
final orderRepositoryProvider = ordersRepositoryProvider;

// Restore the generic stream provider used by OrderHistoryScreen
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getBuyingOrders(userId);
});

final buyingOrdersStreamProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getBuyingOrders(userId);
});

final sellingOrdersStreamProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getSellingOrders(userId);
});