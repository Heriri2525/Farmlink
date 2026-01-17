class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String location;
  final double price;
  final String unit;
  final double quantity;
  final String ownerName;
  final String? ownerId;
  final String description;
  final String? ownerPhone;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.ownerName,
    this.ownerId,
    this.description = '',
    this.ownerPhone,
    this.category = 'Other',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? 'https://picsum.photos/id/237/150/150',
      location: json['location'] as String? ?? 'Unknown',
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'unit',
      quantity: (json['quantity'] as num).toDouble(),
      ownerName: json['owner_name'] as String? ?? 'Farmer',
      ownerId: json['owner_id'] as String?,
      description: json['description'] as String? ?? '',
      ownerPhone: json['owner_phone'] as String?,
      category: json['category'] as String? ?? 'Other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image_url': imageUrl,
      'location': location,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'description': description,
      'owner_phone': ownerPhone,
      'category': category,
      'owner_id': ownerId,
      'owner_name': ownerName,
    };
  }
}
