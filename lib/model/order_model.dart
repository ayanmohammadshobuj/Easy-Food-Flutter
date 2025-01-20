// lib/model/order.dart
import 'order_item.dart';

class Order {
  final int id;
  final String customerName;
  final String orderStatus;
  final DateTime createdAt;
  final double totalPrice;
  final List<OrderItem> orderItems;
  final String paymentMethod;
  final String paymentStatus;
  final String address;

  Order({
    required this.id,
    required this.customerName,
    required this.orderStatus,
    required this.createdAt,
    required this.totalPrice,
    required this.orderItems,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer']['fullName'],
      orderStatus: json['orderStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      totalPrice: json['totalPrice'],
      orderItems: (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      address:
      '${json['apartment']}, ${json['street']}, ${json['city']} (${json['label']})',
    );
  }
}
