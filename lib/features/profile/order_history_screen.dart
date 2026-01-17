import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

import 'package:farmlink/features/orders/order_providers.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final completedOrders = orders.where((o) => o.status.name == 'completed').toList();
          
          if (completedOrders.isEmpty) {
            return const Center(
              child: Text('No completed orders found.'),
            );
          }

          return ListView.builder(
            itemCount: completedOrders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = completedOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(order.productName),
                  subtitle: Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    DateFormat('MMM d, yyyy').format(DateTime.now()), // Placeholder for created_at
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
