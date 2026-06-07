import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/profile_action_response_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/profile_response_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository repository,
  }) : _repository = repository;

  final ProfileRepository _repository;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isSubmitting = false;

  String? errorMessage;
  String? successMessage;

  ProfileModel? profile;

  Future<void> getProfile() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ProfileResponseModel response = await _repository.getProfile();
      profile = response.profile;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (isRefreshing) return;

    isRefreshing = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ProfileResponseModel response = await _repository.getProfile();
      profile = response.profile;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to refresh profile. Please try again.';
    }

    isRefreshing = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String familyName,
    required String address,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ProfileActionResponseModel response =
          await _repository.updateProfile(
        payload: {
          'name': name,
          'email': email,
          'phone': phone,
          'family_name': familyName,
          'address': address,
        },
      );

      if (response.profile != null) {
        profile = response.profile;
      } else if (profile != null) {
        profile = profile!.copyWith(
          name: name,
          email: email,
          phone: phone,
          familyName: familyName,
          address: address,
        );
      }

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to update profile. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final ProfileActionResponseModel response =
          await _repository.changePassword(
        payload: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      successMessage = response.message;
      isSubmitting = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Unable to change password. Please try again.';
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }
}