import 'package:bloc/bloc.dart';
import 'package:understore/features/auth/data/models/user.dart';
import 'package:understore/features/profile/data/repos/profile_repo.dart';
import 'package:meta/meta.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  User? currentUser;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    emit(ProfileLoading());
    try {
      currentUser = await profileRepo.getCurrentUser();
      if (currentUser != null) {
        emit(ProfileLoaded(currentUser!));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    emit(ProfileUpdateLoading());
    try {
      await profileRepo.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
      );
      await loadUserProfile();
      emit(ProfileUpdateSuccess('Profile updated successfully'));
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> updateLocation(String location) async {
    emit(ProfileUpdateLoading());
    try {
      await profileRepo.updateUserLocation(location);
      await loadUserProfile();
      emit(ProfileUpdateSuccess('Location updated successfully'));
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ProfileUpdateLoading());
    try {
      await profileRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ProfileUpdateSuccess('Password changed successfully'));
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await profileRepo.signOut();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
