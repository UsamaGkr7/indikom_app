import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_languages.dart';
import '../../../../core/constants/hive_keys.dart';

// ========== EVENTS ==========
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;

  const ChangeLanguageEvent({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}

// ========== STATES ==========
abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String languageCode;
  final Locale locale;
  final TextDirection textDirection;

  const LanguageLoaded({
    required this.languageCode,
    required this.locale,
    required this.textDirection,
  });

  @override
  List<Object?> get props => [languageCode, locale, textDirection];
}

// ========== BLOC ==========
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final Box _settingsBox;

  LanguageBloc({required Box settingsBox})
      : _settingsBox = settingsBox,
        super(LanguageInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());

    try {
      // Load saved language or default to English
      final savedLanguage = _settingsBox.get(
        HiveKeys.languageCode,
        defaultValue: AppLanguages.english,
      ) as String;

      emit(_createLanguageState(savedLanguage));
    } catch (e) {
      // Fallback to English on error
      emit(_createLanguageState(AppLanguages.english));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());

    try {
      // ✅ ONLY save language - don't touch auth
      await _settingsBox.put(HiveKeys.languageCode, event.languageCode);

      emit(_createLanguageState(event.languageCode));

      // ✅ No router navigation here!
    } catch (e) {
      emit(const LanguageLoaded(
        languageCode: 'en',
        locale: Locale('en'),
        textDirection: TextDirection.ltr,
      ));
    }
  }

  LanguageLoaded _createLanguageState(String languageCode) {
    return LanguageLoaded(
      languageCode: languageCode,
      locale: Locale(languageCode),
      textDirection:
          AppLanguages.languageDirections[languageCode] ?? TextDirection.ltr,
    );
  }
}
