import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final AppDatabase database;

  PurchasesCubit(this.database) : super(PurchasesInitial());

  Future<void> loadData() async {
    emit(PurchasesLoading());
    try {
      final suppliers = await database.getSuppliers();
      final products = await database.getProducts();
      final history = await database.getPurchaseHistory();
      emit(
        PurchasesLoaded(
          suppliers: suppliers,
          products: products,
          purchaseHistory: history,
          tempItems: const [],
        ),
      );
    } catch (e) {
      emit(PurchasesError('فشل في تحميل البيانات: $e'));
    }
  }

  void addItemToTemp(PurchaseItem item) {
    if (state is PurchasesLoaded) {
      final currentState = state as PurchasesLoaded;
      final updatedItems = List<PurchaseItem>.from(currentState.tempItems)
        ..add(item);
      emit(currentState.copyWith(tempItems: updatedItems));
    }
  }

  void removeItemFromTemp(int index) {
    if (state is PurchasesLoaded) {
      final currentState = state as PurchasesLoaded;
      final updatedItems = List<PurchaseItem>.from(currentState.tempItems)
        ..removeAt(index);
      emit(currentState.copyWith(tempItems: updatedItems));
    }
  }

  Future<void> savePurchase({
    required int supplierId,
    required String notes,
  }) async {
    if (state is PurchasesLoaded) {
      final currentState = state as PurchasesLoaded;
      if (currentState.tempItems.isEmpty) return;

      emit(PurchasesLoading());
      try {
        final totalAmount = currentState.tempItems.fold<double>(
          0,
          (sum, item) => sum + (item.quantity * item.purchasePrice),
        );

        final purchase = Purchase(
          supplierId: supplierId,
          date: DateTime.now(),
          totalAmount: totalAmount,
          notes: notes,
        );

        await database.addPurchase(purchase, currentState.tempItems);
        emit(PurchaseSavedSuccess());
        // Reload history
        loadData();
      } catch (e) {
        emit(PurchasesError('فشل في حفظ أمر الشراء: $e'));
      }
    }
  }
}
