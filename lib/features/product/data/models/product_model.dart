class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String? brand;
  final int? category;
  final String? categoryName;
  final int? subCategory;
  final String? subCategoryName;
  final String? supplierName;
  final String price;
  final String? discountPrice;
  final String? dimensions;
  final String? tags;

  final double? effectivePrice;
  final int? discountPercentage;
  final String? thumbnail;
  final String? file; // ✅ Make nullable
  final String? arFile; // ✅ Make nullable
  final bool hasAr;
  final double? rating;
  final int? reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isDailyUseItem;
  final bool isTopDeal;
  final bool isActive;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final List<ProductSpecification> specifications;
  final String? description; // ✅ Make nullable (only in detail)
  final DateTime createdAt;
  final DateTime? updatedAt; // ✅ Make nullable (only in detail)

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.brand,
    this.category,
    this.categoryName,
    this.subCategory,
    this.subCategoryName,
    this.supplierName,
    required this.price,
    this.discountPrice,
    this.effectivePrice,
    this.dimensions,
    this.discountPercentage,
    this.thumbnail,
    this.tags,
    this.file,
    this.arFile,
    this.hasAr = false,
    this.rating,
    this.reviewCount,
    required this.stock,
    this.isFeatured = false,
    this.isDailyUseItem = false,
    this.isTopDeal = false,
    required this.isActive,
    this.images = const [],
    this.variants = const [],
    this.specifications = const [],
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      slug: json['slug'] ?? '',
      brand: json['brand'],
      category: json['category'],
      categoryName: json['category_name'],
      subCategory: json['sub_category'],
      subCategoryName: json['sub_category_name'],
      supplierName: json['supplier_name'],
      price: json['price']?.toString() ?? '0.00',
      discountPrice: json['discount_price']?.toString(),
      dimensions: json['dimensions']?.toString(),
      tags: json['tags']?.toString(),

      effectivePrice: json['effective_price']?.toDouble(),
      discountPercentage: json['discount_percentage'],
      thumbnail: _fixUrl(json['thumbnail']),
      file: _fixUrl(json['file']), // ✅ Can be null
      arFile: _fixUrl(json['ar_file']), // ✅ Can be null
      hasAr: json['has_ar'] ?? false,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviewCount: json['review_count'],
      stock: json['stock'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isDailyUseItem: json['is_daily_use_item'] ?? false,
      isTopDeal: json['is_top_deal'] ?? false,
      isActive: _parseBool(json['is_active']),

      // ✅ Handle lists that might be null or missing
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ProductImage.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specifications: (json['specifications'] as List<dynamic>?)
              ?.map((s) =>
                  ProductSpecification.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],

      description: json['description'], // ✅ Can be null (only in detail)
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null // ✅ Can be null (only in detail)
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // ✅ Helper to parse bool from various types
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  // ✅ Fix URL to use correct base
  static String? _fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    const replacements = {
      'http://127.0.0.1:8000': 'http://192.168.0.105:8000',
      'http://localhost:8000': 'http://192.168.0.105:8000',
      'http://192.168.0.103:8000': 'http://192.168.0.105:8000',
      'http://192.168.1.24:8000': 'http://192.168.0.105:8000',
    };

    for (final entry in replacements.entries) {
      if (url.startsWith(entry.key)) {
        return url.replaceAll(entry.key, entry.value);
      }
    }

    return url;
  }

  // ✅ Helper: Get display image (prefer thumbnail, fallback to file)
  String? get displayImage => thumbnail ?? file;

  // ✅ Helper: Get all image URLs for carousel
  List<String> get allImageUrls {
    final urls = <String>[];
    if (thumbnail != null && thumbnail!.isNotEmpty) urls.add(thumbnail!);
    if (file != null && file!.isNotEmpty && file != thumbnail) urls.add(file!);
    for (final img in images) {
      if (img.image != null && img.image!.isNotEmpty) {
        urls.add(img.image!);
      }
    }
    return urls.isNotEmpty ? urls : ['https://via.placeholder.com/800x600'];
  }
}

// ✅ Nested models remain the same but make fields nullable where needed

class ProductImage {
  final int id;
  final String? image;
  final String? altText;
  final bool isPrimary;
  final int sortOrder;

  ProductImage({
    required this.id,
    this.image,
    this.altText,
    this.isPrimary = false,
    this.sortOrder = 0,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      image: ProductModel._fixUrl(json['image']),
      altText: json['alt_text'],
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class ProductVariant {
  final int id;
  final String? sku;
  final String price;
  final String? discountPrice;
  final double? effectivePrice;
  final int stock;
  final bool isActive;
  final String? thumbnail;
  final String? weight;
  final List<dynamic> variantAttributes;
  final String? variantLabel;

  ProductVariant({
    required this.id,
    this.sku,
    required this.price,
    this.discountPrice,
    this.effectivePrice,
    required this.stock,
    required this.isActive,
    this.thumbnail,
    this.weight,
    this.variantAttributes = const [],
    this.variantLabel,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? 0,
      sku: json['sku'],
      price: json['price']?.toString() ?? '0.00',
      discountPrice: json['discount_price']?.toString(),
      effectivePrice: json['effective_price']?.toDouble(),
      stock: json['stock'] ?? 0,
      isActive: ProductModel._parseBool(json['is_active']),
      thumbnail: ProductModel._fixUrl(json['thumbnail']),
      weight: json['weight']?.toString(),
      variantAttributes: json['variant_attributes'] ?? [],
      variantLabel: json['variant_label'],
    );
  }
}

class ProductSpecification {
  final int id;
  final String key;
  final String value;
  final String? unit;
  final int sortOrder;

  ProductSpecification({
    required this.id,
    required this.key,
    required this.value,
    this.unit,
    this.sortOrder = 0,
  });

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
