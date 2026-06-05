class LoginRequestModel {
  const LoginRequestModel({
    required this.emailOrPhone,
    required this.password,
  });

  final String emailOrPhone;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email_or_phone': emailOrPhone,
      'password': password,
    };
  }
}