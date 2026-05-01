class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ✅ Updated fields based on new API
  final String? category; // ✅ Now String (e.g., "Home Appliances")
  final String? subCategory; // ✅ New field (e.g., "Sofas")
  final String? thumbnail; // ✅ New field - thumbnail image URL
  final String? imageUrl; // ✅ Main image (from 'file' field)
  final String? arFile; // ✅ New field - AR view file URL

  // Optional fields (may be added later)
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
    this.category,
    this.subCategory,
    this.thumbnail,
    this.imageUrl,
    this.arFile,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ✅ Fix mixed base URLs helper
    String? fixUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http://127.0.0.1:8000')) {
        return url.replaceAll(
            'http://127.0.0.1:8000', 'http://192.168.0.103:8000');
      }
      return url;
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

      // ✅ Updated category handling - now direct String
      category: json['category'],

      // ✅ New sub_category field
      subCategory: json['sub_category'],

      // ✅ New thumbnail field
      thumbnail: fixUrl(json['thumbnail']),

      // ✅ Main image from 'file' field
      imageUrl: fixUrl(json['file']),

      // ✅ New AR file field
      arFile: fixUrl(json['ar_file']),

      // Optional fields
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
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (imageUrl != null) 'file': imageUrl,
      if (arFile != null) 'ar_file': arFile,
    };
  }

  // ✅ Helper: Check if product has AR view
  bool get hasARView => arFile != null && arFile!.isNotEmpty;

  // ✅ Helper: Get display image (prefer thumbnail, fallback to main image)
  String? get displayImage => thumbnail ?? imageUrl;
}
