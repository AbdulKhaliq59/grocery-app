class Product {
  final int? id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final String description;
  final double rating;
  final bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.description,
    this.rating = 0.0,
    this.isFavorite = false,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imagePath: map['image_path'],
      category: map['category'],
      description: map['description'],
      rating: map['rating'] ?? 0.0,
      isFavorite: map['is_favorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_path': imagePath,
      'category': category,
      'description': description,
      'rating': rating,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? imagePath,
    String? category,
    String? description,
    double? rating,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
