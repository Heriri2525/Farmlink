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
  });
}

// Dummy Data
final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'Red Ripe Tomatoes',
    imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=500&q=80',
    location: 'Nairobi, Kenya',
    price: 1.20,
    unit: 'kg',
    quantity: 500,
    ownerName: 'John Doe',
  ),
  Product(
    id: '2',
    name: 'Hass Avocados',
    imageUrl: 'https://images.unsplash.com/photo-1523049673856-38866de6c63f?auto=format&fit=crop&w=500&q=80',
    location: 'Kiambu, Kenya',
    price: 0.45,
    unit: 'piece',
    quantity: 2000,
    ownerName: 'Mary Jane',
  ),
  Product(
    id: '3',
    name: 'Organic Carrots',
    imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=500&q=80',
    location: 'Nakuru, Kenya',
    price: 25.00,
    unit: 'sack',
    quantity: 50,
    ownerName: 'Peter Pan',
  ),
  Product(
    id: '4',
    name: 'Irish Potatoes',
    imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=500&q=80',
    location: 'Meru, Kenya',
    price: 32.00,
    unit: 'sack',
    quantity: 120,
    ownerName: 'Alice Wonderland',
  ),
   Product(
    id: '5',
    name: 'Sweet Mangoes',
    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=500&q=80',
    location: 'Machakos, Kenya',
    price: 8.50,
    unit: 'box',
    quantity: 80,
    ownerName: 'Bob Builder',
  ),
];
