part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final User user;

  ProfileLoaded(this.user);
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

final class ProfileUpdateLoading extends ProfileState {}

final class ProfileUpdateSuccess extends ProfileState {
  final String message;

  ProfileUpdateSuccess(this.message);
}

final class ProfileUpdateError extends ProfileState {
  final String message;

  ProfileUpdateError(this.message);
}
