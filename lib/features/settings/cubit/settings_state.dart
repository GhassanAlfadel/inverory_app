import '../../../core/database/models.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final List<PaymentMethod> paymentMethods;

  SettingsLoaded({required this.settings, required this.paymentMethods});

  SettingsLoaded copyWith({
    AppSettings? settings,
    List<PaymentMethod>? paymentMethods,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}

class SettingsActionSuccess extends SettingsState {
  final String message;
  SettingsActionSuccess(this.message);
}
