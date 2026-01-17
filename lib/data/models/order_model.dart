import 'dart:convert';

enum OrderStatus {
  pending,
  completed,
  cancelled;

  String toJson() => name;

  static OrderStatus fromJson(String json) {
    try {
      return values.byName(json);
    } catch (_) {
      // Fallback for older string formats if necessary
      return values.firstWhere(
        (e) => e.name.toLowerCase() == json.toLowerCase(),
        orElse: () => OrderStatus.pending,
      );
    }
  }
}

class Order {
  final String id;
  final String userId;
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
    required this.userId,
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
      id: json['id'],
      userId: json['user_id'] ?? '',
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? 'product',
      totalPrice: (json['total_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      status: OrderStatus.fromJson(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'product_name': productName,
      'total_price': totalPrice,
      'quantity': quantity,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
      other.id == id &&
      other.userId == userId &&
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
      userId.hashCode ^
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
    String? userId,
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
      userId: userId ?? this.userId,
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