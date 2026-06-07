class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.familyName,
    required this.avatarUrl,
    required this.address,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String familyName;
  final String avatarUrl;
  final String address;
  final DateTime createdAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      familyName: json['family_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'family_name': familyName,
      'address': address,
    };
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? familyName,
    String? avatarUrl,
    String? address,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      familyName: familyName ?? this.familyName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}