class AddressModel {
  final int id;
  final String? label;
  final String fullName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    this.label,
    required this.fullName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.isDefault,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      label: json['label'],
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['is_default'] ?? false,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      if (label != null) 'label': label,
      'full_name': fullName,
      'phone': phone,
      'line1': line1,
      if (line2 != null) 'line2': line2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'is_default': isDefault,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  // ✅ Get formatted address
  String get formattedAddress {
    List<String> parts = [];
    if (line1.isNotEmpty) parts.add(line1);
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  // ✅ Get short address (for cards)
  String get shortAddress {
    List<String> parts = [];
    if (line1.isNotEmpty) parts.add(line1);
    if (city.isNotEmpty) parts.add(city);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }
}
