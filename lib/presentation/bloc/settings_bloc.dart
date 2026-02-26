import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;

  ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

// State
class SettingsState extends Equatable {
  final String languageCode;

  const SettingsState({
    this.languageCode = 'kaa',
  });

  Locale get locale => Locale(languageCode);

  // API uchun til kodi (kaa -> uz)
  String get apiLanguage {
    if (languageCode == 'kaa') return 'uz';
    return languageCode;
  }

  SettingsState copyWith({
    String? languageCode,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [languageCode];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  static const String _languageKey = 'language_code';
  static const List<String> supportedLanguages = ['kaa', 'uz', 'ru', 'en'];

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final languageCode = prefs.getString(_languageKey) ?? 'kaa';

    // Qo'llab-quvvatlanmaydigan til bo'lsa, default qilish
    final validCode = supportedLanguages.contains(languageCode)
        ? languageCode
        : 'kaa';

    emit(state.copyWith(languageCode: validCode));
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (supportedLanguages.contains(event.languageCode)) {
      await prefs.setString(_languageKey, event.languageCode);
      emit(state.copyWith(languageCode: event.languageCode));
    }
  }
}