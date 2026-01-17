import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductRepository(this._firestore, this._auth);

  // Stream of products (Real-time) with optional search and category filter
  Stream<List<Product>> streamProducts({String? query, String? category}) {
    var querySnapshot = _firestore
        .collection('products')
        .orderBy('created_at', descending: true)
        .snapshots();

    return querySnapshot.map((snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Map document ID to product ID
        return Product.fromJson(data);
      }).toList();

      return products.where((p) {
        final matchesQuery = query == null || query.isEmpty || 
                            p.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = category == null || category == 'All' || 
                               p.category == category;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> uploadProduct(Product product) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      await _firestore.collection('products').add({
        ...product.toMap(),
        'owner_id': user.uid, // Override just in case or ensure it's correct
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        ...product.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> decrementQuantity(String productId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('products').doc(productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw 'Product does not exist';
        }

        final currentQuantity = (snapshot.data()?['quantity'] as num).toDouble();
        final newQuantity = currentQuantity - amount;

        if (newQuantity < 0) throw 'Not enough stock';

        transaction.update(docRef, {'quantity': newQuantity});
      });
    } catch (e) {
      throw e.toString();
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  return ref.watch(productRepositoryProvider).streamProducts(query: query, category: category);
});

final userProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return ref.watch(productRepositoryProvider).streamProducts().map(
    (products) => products.where((p) => p.ownerId == user.uid).toList(),
  );
});
