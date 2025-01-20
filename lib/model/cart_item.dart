// lib/model/cart_item.dart
class CartItem {
  final int id; // Cart item ID
  final int foodId; // Food ID for API updates
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.foodId, // Added foodId field
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'], // Cart item ID
      foodId: json['food']['id'], // Extract the food ID
      name: json['food']['name'],
      quantity: json['quantity'],
      price: json['food']['price'].toDouble(),
      imageUrl: json['food']['image'],
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}
