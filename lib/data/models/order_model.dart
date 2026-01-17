import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  approved,
  rejected,
  completed,
  cancelled;

  String toJson() => name;

  static OrderStatus fromJson(String json) {
    try {
      return values.byName(json);
    } catch (_) {
      return values.firstWhere(
        (e) => e.name.toLowerCase() == json.toLowerCase(),
        orElse: () => OrderStatus.pending,
      );
    }
  }
}

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final double totalPrice;
  final double quantity;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.totalPrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? 'Product',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromJson(json['status'] ?? 'pending'),
      createdAt: json['created_at'] is Timestamp 
          ? (json['created_at'] as Timestamp).toDate() 
          : DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'product_name': productName,
      'total_price': totalPrice,
      'quantity': quantity,
      'status': status.toJson(),
      'created_at': createdAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
      other.id == id &&
      other.buyerId == buyerId &&
      other.sellerId == sellerId &&
      other.productId == productId &&
      other.productName == productName &&
      other.totalPrice == totalPrice &&
      other.quantity == quantity &&
      other.status == status &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      buyerId.hashCode ^
      sellerId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      totalPrice.hashCode ^
      quantity.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
  }

  Order copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? productId,
    String? productName,
    double? totalPrice,
    double? quantity,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      totalPrice: totalPrice ?? this.totalPrice,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}