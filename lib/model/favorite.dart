// lib/model/favorite.dart
class Favorite {
  final int id;
  final String title;
  final String category;
  final String cuisine;
  final String status;
  final String description;
  final String dpImage;

  Favorite({
    required this.id,
    required this.title,
    required this.category,
    required this.cuisine,
    required this.status,
    required this.description,
    required this.dpImage,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      cuisine: json['cuisine'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      dpImage: json['dpImage'] ?? '',
    );
  }
}