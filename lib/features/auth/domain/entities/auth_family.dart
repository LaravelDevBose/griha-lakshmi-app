class AuthFamily {
  const AuthFamily({
    required this.id,
    required this.name,
    this.currency,
  });

  final int id;
  final String name;
  final String? currency;
}