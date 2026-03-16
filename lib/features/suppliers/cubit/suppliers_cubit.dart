import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final AppDatabase database;

  SuppliersCubit(this.database) : super(SuppliersInitial());

  Future<void> loadSuppliers({String? query}) async {
    emit(SuppliersLoading());
    try {
      var suppliers = await database.getSuppliers();
      if (query != null && query.isNotEmpty) {
        suppliers = suppliers
            .where(
              (s) =>
                  s.name.toLowerCase().contains(query.toLowerCase()) ||
                  (s.phone?.contains(query) ?? false) ||
                  (s.email?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
      }
      emit(SuppliersLoaded(suppliers: suppliers, searchQuery: query));
    } catch (e) {
      emit(SuppliersError('فشل في تحميل الموردين: $e'));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await database.addSupplier(supplier);
      emit(const SupplierActionSuccess('تم إضافة المورد بنجاح'));
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError('فشل في إضافة المورد: $e'));
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await database.updateSupplier(supplier);
      emit(const SupplierActionSuccess('تم تحديث بيانات المورد بنجاح'));
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError('فشل في تحديث بيانات المورد: $e'));
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await database.deleteSupplier(id);
      emit(const SupplierActionSuccess('تم حذف المورد بنجاح'));
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError('فشل في حذف المورد: $e'));
    }
  }
}
