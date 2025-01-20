// lib/model/restaurant.dart
class Restaurant {
  final int id;
  final String name;
  final String cuisineType;
  final String description;
  final String openingHours;
  final String closingHours;
  final bool open;
  final double totalRating;
  final String registrationDate;
  final List<Category> categories;
  final List<Food> foods;
  final RestaurantImages restaurantImages;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.description,
    required this.openingHours,
    required this.closingHours,
    required this.open,
    required this.totalRating,
    required this.registrationDate,
    required this.categories,
    required this.foods,
    required this.restaurantImages,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'] ?? '',
      cuisineType: json['cuisineType'] ?? '',
      description: json['description'] ?? '',
      openingHours: json['openingHours'] ?? '',
      closingHours: json['closingHours'] ?? '',
      open: json['open'] ?? false,
      totalRating: (json['totalRating'] ?? 0).toDouble(),
      registrationDate: json['registrationDate'] ?? '',
      categories: json['categories'] != null
          ? List<Category>.from(json['categories'].map((x) => Category.fromJson(x)))
          : [],
      foods: json['foods'] != null
          ? List<Food>.from(json['foods'].map((x) => Food.fromJson(x)))
          : [],
      restaurantImages: json['restaurantImages'] != null
          ? RestaurantImages.fromJson(json['restaurantImages'])
          : RestaurantImages(id: 0, dpImage: '', coverImage: '', displayImage: ''),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Food {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool available;
  final String creationDate;
  final Category foodCategory;
  final String image;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
    required this.creationDate,
    required this.foodCategory,
    required this.image,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      available: json['available'] ?? false,
      creationDate: json['creationDate'] ?? '',
      foodCategory: Category.fromJson(json['foodCategory']),
      image: json['image'] ?? '',
    );
  }
}

class RestaurantImages {
  final int id;
  final String dpImage;
  final String coverImage;
  final String displayImage;

  RestaurantImages({
    required this.id,
    required this.dpImage,
    required this.coverImage,
    required this.displayImage,
  });

  factory RestaurantImages.fromJson(Map<String, dynamic> json) {
    return RestaurantImages(
      id: json['id'],
      dpImage: json['dpImage'] ?? '',
      coverImage: json['coverImage'] ?? '',
      displayImage: json['displayImage'] ?? '',
    );
  }
}