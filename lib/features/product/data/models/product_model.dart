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
  final int? categoryId; // ✅ Changed: category ID as int
  final String? categoryName; // ✅ Added: category name (if available)
  final String? imageUrl; // ✅ Changed: from 'file' field
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
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse price
    double priceValue =
        double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    // Handle category - can be int (ID) or Map (nested object)
    int? categoryId;
    String? categoryName;

    final categoryData = json['category'];
    if (categoryData is int) {
      categoryId = categoryData;
    } else if (categoryData is Map) {
      categoryId = categoryData['id'];
      categoryName = categoryData['name'];
    }

    // Handle image URL - 'file' field can be null or full URL
    String? imageUrl = json['file'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // ✅ Fix mixed base URLs (127.0.0.1 vs 192.168.x.x)
      if (imageUrl.startsWith('http://127.0.0.1')) {
        imageUrl = imageUrl.replaceAll(
            'http://127.0.0.1:8000', 'http://192.168.0.102:8000');
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
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrl: imageUrl,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviewCount: json['review_count'],
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
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
      if (categoryId != null) 'category': categoryId,
      if (imageUrl != null) 'file': imageUrl,
    };
  }
}
