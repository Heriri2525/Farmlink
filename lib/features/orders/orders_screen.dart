import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/order_model.dart';
import 'package:farmlink/features/orders/order_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:farmlink/core/common/async_value_widget.dart'; // Assuming this exists or will be created

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
            Tab(text: 'selling'),
            Tab(text: 'buying'),
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

// Placeholder for OrderCard - will be moved to its own file later
class OrderCard extends StatelessWidget {
  final Order order;
  final bool isBuyingOrder;

  const OrderCard({super.key, required this.order, required this.isBuyingOrder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.id.substring(0, 8)}...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Product: ${order.productName}'),
            Text('Quantity: ${order.quantity}'),
            Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
            Text('Status: ${order.status.name.toUpperCase()}'),
            Text('Ordered On: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
            if (!isBuyingOrder) // Display buyer info only for selling orders
              Text('Buyer ID: ${order.buyerId.substring(0, 8)}...'),
            if (isBuyingOrder) // Display seller info only for buying orders
              Text('Seller ID: ${order.sellerId.substring(0, 8)}...'),
          ],
        ),
      ),
    );
  }
}