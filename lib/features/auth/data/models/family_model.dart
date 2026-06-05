import '../../domain/entities/auth_family.dart';

class FamilyModel {
  const FamilyModel({
    required this.id,
    required this.name,
    this.currency,
  });

  final int id;
  final String name;
  final String? currency;

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      currency: json['currency']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
    };
  }

  AuthFamily toEntity() {
    return AuthFamily(
      id: id,
      name: name,
      currency: currency,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}