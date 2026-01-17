import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:farmlink/data/models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/notification_repository.dart';

class OrdersRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;

  OrdersRepository(this._firestore, this._notificationRepository);

  Stream<List<Order>> getBuyingOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('buyer_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Order.fromJson(data);
          }).toList();
          // Sort locally to avoid requiring a composite index
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<Order>> getSellingOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('seller_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Order.fromJson(data);
          }).toList();
          // Sort locally to avoid requiring a composite index
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Future<void> createOrder({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String productName,
    required double totalPrice,
    required double quantity,
  }) async {
    final docRef = await _firestore.collection('orders').add({
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'product_name': productName,
      'total_price': totalPrice,
      'quantity': quantity,
      'status': OrderStatus.pending.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });

    // Send notification to seller
    await _notificationRepository.sendNotification(
      userId: sellerId,
      title: 'New Order!',
      body: 'You have a new order for $productName.',
      orderId: docRef.id,
    );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    required String buyerId,
    required String productName,
  }) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status.toJson()});

    // Send notification to buyer
    String title = 'Order Update';
    String body = 'Your order for $productName has been ${status.name}.';
    
    await _notificationRepository.sendNotification(
      userId: buyerId,
      title: title,
      body: body,
      orderId: orderId,
    );
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return OrdersRepository(FirebaseFirestore.instance, notificationRepository);
});

final buyingOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getBuyingOrders(userId);
});

final sellingOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  return ordersRepository.getSellingOrders(userId);
});
