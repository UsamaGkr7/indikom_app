import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/models/banner_model.dart';

// Events
abstract class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

class LoadBannersEvent extends BannerEvent {}

// States
abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerLoaded extends BannerState {
  final List<BannerModel> banners;

  const BannerLoaded({required this.banners});

  @override
  List<Object?> get props => [banners];
}

class BannerError extends BannerState {
  final String message;

  const BannerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BannerRepository _bannerRepository;

  BannerBloc({BannerRepository? bannerRepository})
      : _bannerRepository = bannerRepository ?? BannerRepository(),
        super(BannerInitial()) {
    on<LoadBannersEvent>(_onLoadBanners);
  }

  Future<void> _onLoadBanners(
    LoadBannersEvent event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerLoading());

    try {
      final banners = await _bannerRepository.fetchBanners();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError(message: e.toString()));
    }
  }
}
