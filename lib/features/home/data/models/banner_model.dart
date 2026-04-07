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
      name: json['name'] ?? '',
      bannerFile: json['banner_file'] ?? '',
      isActive: json['is_active'] ?? false,
    );
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
