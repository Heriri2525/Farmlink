import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/notification_model.dart';
import 'package:farmlink/data/repositories/notification_repository.dart';

// Stream of notifications
final notificationsStreamProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.notificationsStream;
});

// Controller for actions
class NotificationController extends Notifier<void> {
  late final NotificationRepository _repository;

  @override
  void build() {
    _repository = ref.watch(notificationRepositoryProvider);
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } catch (e) {
      // Handle error silently or log
    }
  }
}

final notificationControllerProvider = NotifierProvider<NotificationController, void>(() {
  return NotificationController();
});
