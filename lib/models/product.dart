class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;
  final double rating;
  final bool isNew;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    this.rating = 4.5,
    this.isNew = false,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'category': category,
        'price': price,
        'image': image,
        'description': description,
        'rating': rating,
        'isNew': isNew ? 1 : 0,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String,
        category: map['category'] as String,
        price: (map['price'] as num).toDouble(),
        image: map['image'] as String,
        description: map['description'] as String,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
        isNew: map['isNew'] == 1,
      );

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    String? image,
    String? description,
    double? rating,
    bool? isNew,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        price: price ?? this.price,
        image: image ?? this.image,
        description: description ?? this.description,
        rating: rating ?? this.rating,
        isNew: isNew ?? this.isNew,
      );

  String get formattedPrice {
    if (price >= 1000) {
      final k = price / 1000;
      return '\$${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }
}