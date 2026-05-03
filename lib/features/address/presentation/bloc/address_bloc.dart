import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indikom_app/features/address/repositories/address_repository.dart';
import '../../data/models/address_model.dart';

// Events
abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddressesEvent extends AddressEvent {}

class LoadAddressByIdEvent extends AddressEvent {
  final int id;
  const LoadAddressByIdEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateAddressEvent extends AddressEvent {
  final AddressModel address;
  const CreateAddressEvent({required this.address});
  @override
  List<Object?> get props => [address];
}

class UpdateAddressEvent extends AddressEvent {
  final int id;
  final AddressModel address;
  const UpdateAddressEvent({required this.id, required this.address});
  @override
  List<Object?> get props => [id, address];
}

class DeleteAddressEvent extends AddressEvent {
  final int id;
  const DeleteAddressEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class SetDefaultAddressEvent extends AddressEvent {
  final int id;
  const SetDefaultAddressEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

// States
abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<AddressModel> addresses;
  const AddressesLoaded({required this.addresses});
  @override
  List<Object?> get props => [addresses];
}

class AddressLoaded extends AddressState {
  final AddressModel address;
  const AddressLoaded({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddressCreated extends AddressState {
  final AddressModel address;
  const AddressCreated({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddressUpdated extends AddressState {
  final AddressModel address;
  const AddressUpdated({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddressDeleted extends AddressState {}

class AddressDefaultSet extends AddressState {
  final AddressModel address;
  const AddressDefaultSet({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddressError extends AddressState {
  final String message;
  const AddressError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Bloc
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc({AddressRepository? addressRepository})
      : _addressRepository = addressRepository ?? AddressRepository(),
        super(AddressInitial()) {
    on<LoadAddressesEvent>(_onLoadAddresses);
    on<LoadAddressByIdEvent>(_onLoadAddressById);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
    on<SetDefaultAddressEvent>(_onSetDefaultAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final addresses = await _addressRepository.fetchAddresses();
      emit(AddressesLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onLoadAddressById(
    LoadAddressByIdEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _addressRepository.fetchAddressById(event.id);
      emit(AddressLoaded(address: address));
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onCreateAddress(
    CreateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _addressRepository.createAddress(event.address);
      emit(AddressCreated(address: address));
      // Reload addresses after creation
      add(LoadAddressesEvent());
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address =
          await _addressRepository.updateAddress(event.id, event.address);
      emit(AddressUpdated(address: address));
      // Reload addresses after update
      add(LoadAddressesEvent());
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      await _addressRepository.deleteAddress(event.id);
      emit(AddressDeleted());
      // Reload addresses after deletion
      add(LoadAddressesEvent());
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _addressRepository.setDefaultAddress(event.id);
      emit(AddressDefaultSet(address: address));
      // Reload addresses after setting default
      add(LoadAddressesEvent());
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }
}
