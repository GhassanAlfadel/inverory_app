import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final AppDatabase _database;

  InvoicesCubit(this._database) : super(InvoicesInitial());

  Future<void> loadInvoices() async {
    emit(InvoicesLoading());
    try {
      final invoices = await _database.getSalesHistory();
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(InvoicesError('فشل تحميل الفواتير: $e'));
    }
  }

  Future<void> loadInvoiceDetails(int saleId) async {
    emit(InvoicesLoading());
    try {
      final sales = await _database.getSalesHistory();
      final invoice = sales.firstWhere((s) => s['id'] == saleId);
      final items = await _database.getSaleItems(saleId);
      emit(InvoiceDetailsLoaded(invoice, items));
    } catch (e) {
      emit(InvoicesError('فشل تحميل تفاصيل الفاتورة: $e'));
    }
  }

  Future<void> returnItem(int saleId, int saleItemId, int quantity) async {
    try {
      await _database.returnSaleItem(saleItemId, quantity);
      // Reload details after return
      await loadInvoiceDetails(saleId);
    } catch (e) {
      emit(InvoicesError('فشل عملية الإرجاع: $e'));
      // Reload previous state or details to reset error
      await loadInvoiceDetails(saleId);
    }
  }
}
