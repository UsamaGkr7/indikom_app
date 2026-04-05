import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> data;
  const UpdateProfileEvent({required this.data});
  @override
  List<Object?> get props => [data];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  const ProfileLoaded({required this.userData});
  @override
  List<Object?> get props => [userData];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    // TODO: Load profile from API
    emit(const ProfileLoaded(userData: {}));
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    // TODO: Update profile via API
    emit(ProfileLoaded(userData: event.data));
  }
}
