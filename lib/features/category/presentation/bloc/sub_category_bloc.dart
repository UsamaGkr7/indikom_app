import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/sub_category_repository.dart';
import '../../data/models/sub_category_model.dart';

// Events
abstract class SubCategoryEvent extends Equatable {
  const SubCategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubCategoriesEvent extends SubCategoryEvent {
  final int? categoryId; // ✅ Changed to int

  const LoadSubCategoriesEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

// Update the handler:

// States
abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoriesLoaded extends SubCategoryState {
  final List<SubCategoryModel> subCategories;

  const SubCategoriesLoaded({required this.subCategories});

  @override
  List<Object?> get props => [subCategories];
}

class SubCategoryError extends SubCategoryState {
  final String message;

  const SubCategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryRepository _subCategoryRepository;

  SubCategoryBloc({SubCategoryRepository? subCategoryRepository})
      : _subCategoryRepository =
            subCategoryRepository ?? SubCategoryRepository(),
        super(SubCategoryInitial()) {
    on<LoadSubCategoriesEvent>(_onLoadSubCategories);
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategoriesEvent event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    try {
      final subCategories = await _subCategoryRepository.fetchSubCategories(
        categoryId: event.categoryId, // ✅ Pass categoryId (int)
      );
      emit(SubCategoriesLoaded(subCategories: subCategories));
    } catch (e) {
      emit(SubCategoryError(message: e.toString()));
    }
  }
}
