import '../datasources/profile_remote_datasource.dart';
import '../models/profile_action_response_model.dart';
import '../models/profile_response_model.dart';

class ProfileRepository {
  ProfileRepository({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  Future<ProfileResponseModel> getProfile() {
    return _remoteDataSource.getProfile();
  }

  Future<ProfileActionResponseModel> updateProfile({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.updateProfile(payload: payload);
  }

  Future<ProfileActionResponseModel> changePassword({
    required Map<String, dynamic> payload,
  }) {
    return _remoteDataSource.changePassword(payload: payload);
  }
}