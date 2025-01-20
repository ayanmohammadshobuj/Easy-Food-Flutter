class Order {
  final int restaurantId;
  final String paymentMethod;
  final String paymentStatus;
  final String apartment;
  final String street;
  final String city;
  final String landmark;
  final String label;
  final String phone;

  Order({
    required this.restaurantId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.apartment,
    required this.street,
    required this.city,
    required this.landmark,
    required this.label,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'apartment': apartment,
      'street': street,
      'city': city,
      'landmark': landmark,
      'label': label,
      'phone': phone,
    };
  }
}