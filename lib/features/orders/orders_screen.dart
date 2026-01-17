import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/order_model.dart';
import 'package:farmlink/features/orders/order_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:farmlink/core/common/async_value_widget.dart';
import 'package:farmlink/data/repositories/orders_repository.dart';
import 'package:farmlink/data/repositories/product_repository.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Buying'),
            Tab(text: 'Selling'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyingOrdersList(currentUserId),
          _buildSellingOrdersList(currentUserId),
        ],
      ),
    );
  }

  Widget _buildBuyingOrdersList(String userId) {
    final buyingOrdersAsyncValue = ref.watch(buyingOrdersStreamProvider(userId));
    return AsyncValueWidget<List<Order>>(
      value: buyingOrdersAsyncValue,
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No buying orders yet.'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order, isBuyingOrder: true);
          },
        );
      },
    );
  }

  Widget _buildSellingOrdersList(String userId) {
    final sellingOrdersAsyncValue = ref.watch(sellingOrdersStreamProvider(userId));
    return AsyncValueWidget<List<Order>>(
      value: sellingOrdersAsyncValue,
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No selling orders yet.'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order, isBuyingOrder: false);
          },
        );
      },
    );
  }
}

class OrderCard extends ConsumerWidget {
  final Order order;
  final bool isBuyingOrder;

  const OrderCard({super.key, required this.order, required this.isBuyingOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.id.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Product: ${order.productName}'),
            Text('Quantity: ${order.quantity}'),
            Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
            Text('Ordered On: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
            if (isBuyingOrder)
              Text('Seller ID: ${order.sellerId.substring(0, 8)}...'),
            if (!isBuyingOrder)
              Text('Buyer ID: ${order.buyerId.substring(0, 8)}...'),
            
            if (!isBuyingOrder && order.status == OrderStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleStatusUpdate(context, ref, OrderStatus.approved),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleStatusUpdate(context, ref, OrderStatus.rejected),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.approved:
        color = Colors.green;
        break;
      case OrderStatus.rejected:
        color = Colors.red;
        break;
      case OrderStatus.completed:
        color = Colors.blue;
        break;
      case OrderStatus.cancelled:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, WidgetRef ref, OrderStatus status) async {
    try {
      await ref.read(ordersRepositoryProvider).updateOrderStatus(
        orderId: order.id,
        status: status,
        buyerId: order.buyerId,
        productName: order.productName,
      );
      
      if (status == OrderStatus.approved) {
        // Decrement product quantity only on approval? 
        // User said: "Product quantity must update when a user places an order"
        // Actually, usually it's on placement, but approval is safer. 
        // Let's stick to user request: "when a user places an order" -> handled in product_details_screen.dart
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${status.name} successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}