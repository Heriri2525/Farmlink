import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  // Fetch initial notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => AppNotification.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw e.toString();
    }
  }

  // Stream of realtime notifications
  Stream<List<AppNotification>> get notificationsStream {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // We can use a simple stream transform here, but Supabase also supports exact stream
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => AppNotification.fromJson(e)).toList());
  }

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId, // Added optional orderId parameter
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        if (orderId != null) 'order_id': orderId, // Conditionally add order_id
      });
    } catch (e) {
      throw e.toString();
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});
