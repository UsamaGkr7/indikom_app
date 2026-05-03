class BannerModel {
  final int id;
  final String name;
  final String bannerFile;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.name,
    required this.bannerFile,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Banner',
      bannerFile: _fixUrl(json['banner_file'] ?? json['bannerFile'] ?? ''),
      isActive: _parseBool(json['is_active']),
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
  static String _fixUrl(String url) {
    if (url.isEmpty) return '';

    // If URL already starts with http, return as-is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // But fix if it's localhost or wrong IP
      const replacements = {
        'http://127.0.0.1:8000': 'http://192.168.0.105:8000',
        'http://localhost:8000': 'http://192.168.0.105:8000',
        'http://192.168.0.105:8000': 'http://192.168.0.105:8000',
      };

      for (final entry in replacements.entries) {
        if (url.startsWith(entry.key)) {
          return url.replaceAll(entry.key, entry.value);
        }
      }

      return url;
    }

    // If relative path, prepend base URL
    return 'http://192.168.0.105:8000$url';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'banner_file': bannerFile,
      'is_active': isActive,
    };
  }
}
