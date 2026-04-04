import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> categories;
  final List<dynamic> featuredProducts;
  final List<dynamic> banners;

  const HomeLoaded({
    required this.categories,
    required this.featuredProducts,
    required this.banners,
  });

  @override
  List<Object?> get props => [categories, featuredProducts, banners];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // TODO: Call API to fetch home data
      await Future.delayed(const Duration(seconds: 1));

      emit(const HomeLoaded(
        categories: [],
        featuredProducts: [],
        banners: [],
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
