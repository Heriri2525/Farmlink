import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/product_repository.dart';
import 'package:farmlink/data/repositories/storage_repository.dart';
import 'package:farmlink/data/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _unit = 'kg';
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _qtyController.text = widget.product!.quantity.toString();
      _locationController.text = widget.product!.location;
      _unit = widget.product!.unit;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'List New Product'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: (_imageFile == null && (widget.product?.imageUrl == null || widget.product!.imageUrl.contains('via.placeholder')))
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  const Text('Add Product Image', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _imageFile != null
                                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                                      : Image.network(widget.product!.imageUrl, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withOpacity(0.5),
                                    child: IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.white),
                                      onPressed: _pickImage,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
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
                          validator: (value) => value!.isEmpty ? 'Required' : null,
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
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          String? imageUrl;
                          if (_imageFile != null) {
                            final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                            imageUrl = await ref
                                .read(storageRepositoryProvider)
                                .uploadProductImage(_imageFile!, fileName);
                          }

                          final newProduct = Product(
                            id: widget.product?.id ?? '',
                            name: _nameController.text,
                            imageUrl: imageUrl ?? widget.product?.imageUrl ?? 'https://picsum.photos/500',
                            location: _locationController.text,
                            price: double.parse(_priceController.text),
                            unit: _unit,
                            quantity: double.parse(_qtyController.text),
                            ownerName: widget.product?.ownerName ?? 'Farmer',
                            ownerId: widget.product?.ownerId,
                          );

                          if (isEdit) {
                            await ref.read(productRepositoryProvider).updateProduct(newProduct);
                          } else {
                            await ref.read(productRepositoryProvider).uploadProduct(newProduct);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEdit ? 'Product Updated!' : 'Product Listed!'))
                            );
                            
                            if (!isEdit) {
                              // Clear for next time or if user stays
                              _nameController.clear();
                              _priceController.clear();
                              _qtyController.clear();
                              _locationController.clear();
                              setState(() {
                                _imageFile = null;
                                _unit = 'kg';
                              });
                            }
                            
                            context.pop();
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
