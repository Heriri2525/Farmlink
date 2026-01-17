import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farmlink/data/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/orders_repository.dart';
import 'package:farmlink/data/repositories/auth_repository.dart';
import 'package:farmlink/data/repositories/product_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:farmlink/features/orders/order_providers.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _isOrdering = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showSellerInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seller Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(widget.product.ownerName),
              subtitle: const Text('Verified Seller'),
            ),
            if (widget.product.ownerPhone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(widget.product.ownerPhone!),
                onTap: () => _launchUrl('tel:${widget.product.ownerPhone}'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Optionally filter search by owner_id if we have a way to pass it
                  ref.read(searchQueryProvider.notifier).state = widget.product.ownerName;
                  context.push('/search');
                },
                child: const Text('View All Products by Seller'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
            widget.product.name, 
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Hero(
                        tag: widget.product.id,
                        child: Container(
                          width: double.infinity,
                          height: 350,
                          color: Colors.grey[100],
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          widget.product.category,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Text('Price', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${widget.product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' / ${widget.product.unit}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                                ),
                                const Spacer(),
                                Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                   decoration: BoxDecoration(
                                     color: Colors.green[50], 
                                     borderRadius: BorderRadius.circular(20),
                                   ),
                                   child: Row(
                                     children: [
                                       Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                                       const SizedBox(width: 4),
                                       Text(
                                         'In Stock (${widget.product.quantity.toInt()})',
                                         style: TextStyle(
                                           color: Colors.green[700],
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                     ],
                                   ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Seller Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                   CircleAvatar(
                                     backgroundColor: Colors.blue[100],
                                     child: Text(
                                       widget.product.ownerName.isNotEmpty ? widget.product.ownerName.substring(0, 1).toUpperCase() : 'V', 
                                       style: TextStyle(color: Colors.blue[800]),
                                     ),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(widget.product.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                         Text(widget.product.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                       ],
                                     ),
                                   ),
                                   TextButton(
                                     onPressed: () => _showSellerInfo(context), 
                                     child: const Text('Visit More')
                                   ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            const Text(
                              'Description',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.description.isNotEmpty 
                                ? widget.product.description 
                                : 'Freshly harvested ${widget.product.name} from the fertile lands of ${widget.product.location}. Best quality guaranteed.',
                              style: TextStyle(color: Colors.grey[700], height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isOrdering || widget.product.quantity <= 0 ? null : () async {
                          final buyer = ref.read(authRepositoryProvider).currentUser;
                          if (buyer == null) return;
                          
                          if (buyer == widget.product.ownerId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You cannot order your own product!'))
                            );
                            return;
                          }

                          setState(() => _isOrdering = true);
                          try {
                            const double quantityToOrder = 1.0;
                            
                            // 1. Create Order
                            await ref.read(ordersRepositoryProvider).createOrder(
                              buyerId: buyer,
                              sellerId: widget.product.ownerId!,
                              productId: widget.product.id,
                              productName: widget.product.name,
                              totalPrice: widget.product.price * quantityToOrder,
                              quantity: quantityToOrder,
                            );
                            
                            // 2. Decrement Quantity
                            await ref.read(productRepositoryProvider).decrementQuantity(widget.product.id, quantityToOrder);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order Placed Successfully!'))
                              );
                              context.go('/orders');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'))
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isOrdering = false);
                          }
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: Text(widget.product.quantity <= 0 ? 'Out of Stock' : (_isOrdering ? 'Placing Order...' : 'Place Order')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C6EF5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isOrdering)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
