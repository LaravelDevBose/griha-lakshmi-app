class AuthUser {
  const AuthUser({
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
}