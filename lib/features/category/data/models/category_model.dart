class CategoryModel {
  final int id;
  final int? parent;
  final String name;
  final String slug;
  final String? thumbnail;
  final String? icon;
  final String fullPath;
  final bool isActive;
  final int sortOrder;

  CategoryModel({
    required this.id,
    this.parent,
    required this.name,
    required this.slug,
    this.thumbnail,
    this.icon,
    required this.fullPath,
    required this.isActive,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      parent: json['parent'],
      name: json['name'] ?? 'Unnamed Category',
      slug: json['slug'] ?? '',
      thumbnail: _fixUrl(json['thumbnail']),
      icon: _fixUrl(json['icon']),
      fullPath: json['full_path'] ?? json['name'] ?? '',

      // ✅ Properly parse is_active - handle bool, int, or string
      isActive: _parseBool(json['is_active']),

      sortOrder: json['sort_order'] ?? 0,
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
    return false; // Default fallback
  }

  // ✅ Fix URL to use correct base URL
  static String? _fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // ✅ Updated to match your API server
    const oldBaseUrl = 'http://127.0.0.1:8000';
    const newBaseUrl = 'http://192.168.0.105:8000';

    if (url.startsWith(oldBaseUrl)) {
      return url.replaceAll(oldBaseUrl, newBaseUrl);
    }

    // Also handle if URL already has correct base
    if (url.startsWith(newBaseUrl)) {
      return url;
    }

    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (parent != null) 'parent': parent,
      'name': name,
      'slug': slug,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (icon != null) 'icon': icon,
      'full_path': fullPath,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
