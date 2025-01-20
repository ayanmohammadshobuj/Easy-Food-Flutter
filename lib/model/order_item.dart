// lib/model/order_item.dart
class OrderItem {
  final int id;
  final int quantity;
  final double totalPrice;
  final String foodName;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.totalPrice,
    required this.foodName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'],
      totalPrice: json['totalPrice'],
      foodName: json['food']['name'],
    );
  }
}
