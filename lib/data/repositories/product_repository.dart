import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmlink/data/models/product.dart';

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  // Stream of products (Real-time)
  Stream<List<Product>> get productsStream {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Product(
              id: e['id'],
              name: e['name'],
              imageUrl: e['image_url'] ?? 'https://picsum.photos/id/237/150/150', // Fallback
              location: e['location'] ?? 'Unknown',
              price: (e['price'] as num).toDouble(),
              unit: e['unit'] ?? 'unit',
              quantity: (e['quantity'] as num).toDouble(),
              ownerName: 'Farmer', // ideally join with profiles
              ownerId: e['owner_id'],
            )).toList());
  }

  Future<void> uploadProduct(Product product) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      await _supabase.from('products').insert({
        'owner_id': user.id,
        'name': product.name,
        'image_url': product.imageUrl,
        'location': product.location,
        'price': product.price,
        'unit': product.unit,
        'quantity': product.quantity,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabase.from('products').update({
        'name': product.name,
        'image_url': product.imageUrl,
        'location': product.location,
        'price': product.price,
        'unit': product.unit,
        'quantity': product.quantity,
      }).eq('id', product.id);
    } catch (e) {
      throw e.toString();
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).productsStream;
});

final userProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);
  
  return ref.watch(productRepositoryProvider).productsStream.map(
    (products) => products.where((p) => p.ownerId == user.id).toList(),
  );
});
