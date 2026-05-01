class CategoryModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String? thumbnail;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    this.thumbnail,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Category',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      thumbnail: _fixUrl(json['thumbnail']),
    );
  }

  // ✅ Fix URL to use correct base
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
      'name': name,
      'description': description,
      'is_active': isActive,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}
