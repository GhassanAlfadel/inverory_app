import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AppDatabase _database;

  SettingsCubit(this._database) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await _database.getSettings();
      final methods = await _database.getPaymentMethods();
      emit(SettingsLoaded(settings: settings, paymentMethods: methods));
    } catch (e) {
      emit(SettingsError('فشل في تحميل الإعدادات: $e'));
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _database.updateSettings(settings);
      emit(SettingsActionSuccess('تم حفظ الإعدادات العامة بنجاح'));
      loadSettings();
    } catch (e) {
      emit(SettingsError('فشل في حفظ الإعدادات: $e'));
    }
  }

  Future<void> addPaymentMethod(String name) async {
    try {
      await _database.addPaymentMethod(PaymentMethod(name: name));
      emit(SettingsActionSuccess('تم إضافة وسيلة دفع جديدة'));
      loadSettings();
    } catch (e) {
      emit(SettingsError('فشل في إضافة وسيلة الدفع: $e'));
    }
  }

  Future<void> updatePaymentMethod(PaymentMethod method) async {
    try {
      await _database.updatePaymentMethod(method);
      emit(SettingsActionSuccess('تم تحديث وسيلة الدفع بنجاح'));
      loadSettings();
    } catch (e) {
      emit(SettingsError('فشل في تحديث وسيلة الدفع: $e'));
    }
  }

  Future<void> deletePaymentMethod(int id) async {
    try {
      await _database.deletePaymentMethod(id);
      emit(SettingsActionSuccess('تم حذف وسيلة الدفع بنجاح'));
      loadSettings();
    } catch (e) {
      emit(SettingsError('فشل في حذف وسيلة الدفع: $e'));
    }
  }

  Future<void> resetDatabase() async {
    try {
      await _database.resetDatabase();
      emit(
        SettingsActionSuccess(
          'تم تصفير جميع البيانات بنجاح (باستثناء المستخدمين)',
        ),
      );
      loadSettings();
    } catch (e) {
      emit(SettingsError('فشل في تصفير البيانات: $e'));
    }
  }
}
