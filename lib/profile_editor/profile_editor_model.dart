class UserProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String country;
  final String gender;
  final String avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone = '',
    this.address = '',
    this.country = 'Malaysia',
    this.gender = 'Female',
    this.avatar = '',
  });

  // Create from JSON (from API)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString().split('@').first ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Malaysia',
      gender: json['gender']?.toString() ?? 'Female',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  // Convert to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'country': country,
      'gender': gender,
      'avatar': avatar,
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? country,
    String? gender,
    String? avatar,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
    );
  }

  // Get full image URL
  String getFullAvatarUrl(String baseUrl) {
    if (avatar.isEmpty) return '';
    if (avatar.startsWith('http')) return avatar;
    if (avatar.startsWith('uploads/')) return '$baseUrl/$avatar';
    return avatar;
  }

  // Display name with fallback
  String get displayName => name.isNotEmpty ? name : 'User';

  // Display email with fallback
  String get displayEmail => email.isNotEmpty ? email : 'youremail@domain.com';

  // Display phone with fallback
  String get displayPhone => phone.isNotEmpty ? phone : '123-456-7890';

  // Check if profile is complete
  bool get isComplete {
    return name.isNotEmpty &&
           email.isNotEmpty &&
           phone.isNotEmpty &&
           address.isNotEmpty;
  }
}