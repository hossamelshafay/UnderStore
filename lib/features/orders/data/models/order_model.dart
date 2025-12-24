import '../../../cart/data/models/cart.dart';

enum PaymentMethod { card, cash }

enum OrderStatus { pending, processing, delivered, cancelled }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String phoneNumber;
  final PaymentMethod paymentMethod;
  final String? cardNumber;
  final OrderStatus status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    this.cardNumber,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'],
      phoneNumber: json['phoneNumber'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      ),
      cardNumber: json['cardNumber'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod.name,
      'cardNumber': cardNumber,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    String? deliveryAddress,
    String? phoneNumber,
    PaymentMethod? paymentMethod,
    String? cardNumber,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
