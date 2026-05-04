class SubCategoryModel {
  final int id;
  final int category; // ✅ Changed: Now int (category ID), not String name
  final String name;
  final String slug; // ✅ New: URL-friendly name
  final String description;
  final bool isActive;
  final String? thumbnail;
  final int sortOrder; // ✅ New: display order

  SubCategoryModel({
    required this.id,
    required this.category,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    this.thumbnail,
    required this.sortOrder,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? 0, // ✅ Now int
      name: json['name'] ?? 'Unnamed Sub-Category',
      slug: json['slug'] ?? '', // ✅ New field
      description: json['description'] ?? '',
      isActive: _parseBool(json['is_active']), // ✅ Handle bool/int/string
      thumbnail: _fixUrl(json['thumbnail']),
      sortOrder: json['sort_order'] ?? 0, // ✅ New field
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
      'http://127.0.0.1:8000': 'http://192.168.0.102:8000',
      'http://localhost:8000': 'http://192.168.0.102:8000',
      'http://192.168.0.103:8000': 'http://192.168.0.102:8000',
      'http://192.168.1.24:8000': 'http://192.168.0.102:8000',
    };

    for (final entry in replacements.entries) {
      if (url.startsWith(entry.key)) {
        return url.replaceAll(entry.key, entry.value);
      }
    }

    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'slug': slug,
      'description': description,
      'is_active': isActive,
      if (thumbnail != null) 'thumbnail': thumbnail,
      'sort_order': sortOrder,
    };
  }
}
