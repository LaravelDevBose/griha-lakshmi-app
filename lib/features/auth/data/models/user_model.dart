import '../../domain/entities/auth_user.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.familyId,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final int? familyId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      familyId: _parseNullableInt(json['family_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'family_id': familyId,
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      familyId: familyId,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}