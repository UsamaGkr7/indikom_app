class SubCategoryModel {
  final int id;
  final String category;
  final String name;
  final String description;
  final bool isActive;
  final String? thumbnail;

  SubCategoryModel({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.isActive,
    this.thumbnail,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      name: json['name'] ?? 'Unnamed Sub-Category',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      thumbnail: _fixUrl(json['thumbnail']),
    );
  }

  static String? _fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://127.0.0.1:8000')) {
      return url.replaceAll(
          'http://127.0.0.1:8000', 'http://192.168.0.103:8000');
    }
    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'is_active': isActive,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}
