import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/product_repository.dart';
import 'package:go_router/go_router.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(userProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: productsAsync.when(
        data: (products) {
          // In a real app, we'd filter by seller_id in the repository
          // For now, these are all products. Filtering by a placeholder logic.
          final myProducts = products; // Assuming for demo all are mine or repository filters it

          if (myProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('You have no active listings', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myProducts.length,
            itemBuilder: (context, index) {
              final product = myProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${product.price} / ${product.unit} • ${product.quantity.toInt()} left'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/add', extra: product);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Product?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(productRepositoryProvider).deleteProduct(product.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add');
        },
        label: const Text('Add New'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
