class OrderDbModel {
  final int? id;
  final String orderId;
  final String userId;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String deliveryAddress;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  OrderDbModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.phoneNumber,
    this.latitude = 0.0,
    this.longitude = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory OrderDbModel.fromMap(Map<String, dynamic> map) {
    return OrderDbModel(
      id: map['id'] as int?,
      orderId: map['orderId'] as String,
      userId: map['userId'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String,
      deliveryAddress: map['deliveryAddress'] as String,
      phoneNumber: map['phoneNumber'] as String,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'OrderDbModel(orderId: $orderId, userId: $userId, totalAmount: $totalAmount, status: $status)';
  }
}

class OrderItemDbModel {
  final int? id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;

  OrderItemDbModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create from Map
  factory OrderItemDbModel.fromMap(Map<String, dynamic> map) {
    return OrderItemDbModel(
      id: map['id'] as int?,
      orderId: map['orderId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      productImage: map['productImage'] as String?,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}
