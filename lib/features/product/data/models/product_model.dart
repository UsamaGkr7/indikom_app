class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int supplier;
  final String? imageUrl;
  final String? category;
  final List<String>? images;
  final double? rating;
  final int? reviewCount;
  final double? originalPrice;
  final double? discount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.supplier,
    this.imageUrl,
    this.category,
    this.images,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse price to calculate discount if needed
    double priceValue = double.tryParse(json['price'].toString()) ?? 0.0;
    double? originalPrice;
    double? discount;

    // You can add logic here if API provides original price
    // For now, using placeholder logic
    if (json['original_price'] != null) {
      originalPrice = double.tryParse(json['original_price'].toString());
      if (originalPrice != null && originalPrice > priceValue) {
        discount = ((originalPrice - priceValue) / originalPrice) * 100;
      }
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      supplier: json['supplier'] ?? 0,
      imageUrl: json['image'] ?? json['imageUrl'],
      category: json['category'] ?? json['category_name'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviewCount: json['review_count'],
      originalPrice: originalPrice,
      discount: discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'supplier': supplier,
      if (imageUrl != null) 'image': imageUrl,
      if (category != null) 'category': category,
    };
  }
}
