import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import 'purchase_details_state.dart';

class PurchaseDetailsCubit extends Cubit<PurchaseDetailsState> {
  final AppDatabase database;

  PurchaseDetailsCubit(this.database) : super(PurchaseDetailsInitial());

  Future<void> loadPurchaseDetails(int id) async {
    emit(PurchaseDetailsLoading());
    try {
      final purchase = await database.getPurchaseById(id);
      if (purchase != null) {
        final items = await database.getPurchaseItems(id);
        emit(PurchaseDetailsLoaded(purchase: purchase, items: items));
      } else {
        emit(const PurchaseDetailsError('أمر الشراء غير موجود'));
      }
    } catch (e) {
      emit(PurchaseDetailsError('فشل في تحميل تفاصيل أمر الشراء: $e'));
    }
  }
}
