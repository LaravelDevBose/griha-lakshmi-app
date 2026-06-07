import 'profile_model.dart';

class ProfileActionResponseModel {
  const ProfileActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.profile,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final ProfileModel? profile;

  factory ProfileActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic userJson = data['user'];

    return ProfileActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      profile: userJson is Map<String, dynamic>
          ? ProfileModel.fromJson(userJson)
          : null,
    );
  }
}