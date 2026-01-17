import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository(this._firestore, this._auth);

  // Fetch initial notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppNotification.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
    } catch (e) {
      throw e.toString();
    }
  }

  // Stream of realtime notifications
  Stream<List<AppNotification>> get notificationsStream {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return AppNotification.fromJson(data);
          }).toList();
          // Sort locally to avoid requiring a composite index
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        });
  }

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'user_id': userId,
        'title': title,
        'body': body,
        'is_read': false,
        if (orderId != null) 'order_id': orderId,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});
