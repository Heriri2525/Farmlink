import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/product_repository.dart';
import 'package:farmlink/data/models/product.dart';
import 'package:farmlink/data/repositories/profile_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _imageUrlController;
  
  String _unit = 'kg';
  String _category = 'Vegetables';
  bool _isLoading = false;

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Poultry',
    'Meat',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _qtyController = TextEditingController(text: widget.product?.quantity.toString());
    _locationController = TextEditingController(text: widget.product?.location);
    _descriptionController = TextEditingController(text: widget.product?.description);
    _phoneController = TextEditingController(text: widget.product?.ownerPhone);
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl);
    _unit = widget.product?.unit ?? 'kg';
    _category = widget.product?.category ?? 'Vegetables';
  }

  // Image logic simplified to URL only as requested

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'List New Product'),
      ),
      body: profileAsync.when(
        data: (profile) {
          final username = profile?.name ?? 'Vendor';
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text('Image Preview', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const Text('(Enter a URL below)', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, color: Colors.red[300]),
                                        const Text('Invalid Image URL', style: TextStyle(color: Colors.red, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Product Image URL',
                          hintText: 'https://example.com/image.jpg',
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.startsWith('http')) return 'Must start with http/https';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          hintText: 'e.g. Red Onions',
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe your product...',
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _category,
                        items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _category = v!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                prefixText: '\$ ',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _unit,
                              items: ['kg', 'sack', 'piece', 'box'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _unit = v!;
                                });
                              },
                              decoration: const InputDecoration(labelText: 'Unit'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Available Quantity',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Seller Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              String? imageUrl = _imageUrlController.text.trim();
                              
                              if (imageUrl.isEmpty) {
                                // Default high-quality placeholder if no URL provided
                                imageUrl = 'https://picsum.photos/seed/${_nameController.text}/600/400';
                              }

                              final newProduct = Product(
                                id: widget.product?.id ?? '',
                                name: _nameController.text,
                                imageUrl: imageUrl ?? widget.product?.imageUrl ?? '',
                                location: _locationController.text,
                                price: double.parse(_priceController.text),
                                unit: _unit,
                                quantity: double.parse(_qtyController.text),
                                ownerName: username,
                                ownerId: FirebaseAuth.instance.currentUser?.uid,
                                description: _descriptionController.text,
                                ownerPhone: _phoneController.text,
                                category: _category,
                              );

                              if (isEdit) {
                                await ref.read(productRepositoryProvider).updateProduct(newProduct);
                              } else {
                                await ref.read(productRepositoryProvider).uploadProduct(newProduct);
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEdit ? 'Product Updated!' : 'Product Listed!'),
                                    backgroundColor: Colors.green,
                                  )
                                );
                                if (Navigator.canPop(context)) {
                                  context.pop();
                                } else {
                                  // If on the "Add" tab, maybe we don't pop but clear?
                                  // For now, let's assume it's always poppable or we stay there.
                                  // In HomeScreen it's an IndexedStack, so popping won't work if it's the tab.
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Post Listing'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
