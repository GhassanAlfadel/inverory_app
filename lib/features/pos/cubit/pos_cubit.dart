import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'pos_state.dart';

class POSCubit extends Cubit<POSState> {
  final AppDatabase _database;

  POSCubit(this._database) : super(POSInitial());

  Future<void> checkShift(int userId) async {
    emit(POSLoading());
    try {
      final activeShift = await _database.getActiveShift(userId);
      final categories = await _database.getCategories();
      if (activeShift != null) {
        emit(POSActive(shift: activeShift, categories: categories));
      } else {
        emit(POSNoActiveShift());
      }
    } catch (e) {
      emit(POSError('خطأ في التحقق من الوردية: $e'));
    }
  }

  Future<void> startNewShift(int userId, double startBalance) async {
    emit(POSLoading());
    try {
      final shift = Shift(
        userId: userId,
        startTime: DateTime.now(),
        startBalance: startBalance,
      );
      final id = await _database.startShift(shift);
      final categories = await _database.getCategories();
      emit(
        POSActive(
          shift: Shift(
            id: id,
            userId: userId,
            startTime: shift.startTime,
            startBalance: startBalance,
          ),
          categories: categories,
        ),
      );
    } catch (e) {
      emit(POSError('فشل في بدء الوردية: $e'));
    }
  }

  Future<void> searchProducts(String query) async {
    if (state is! POSActive) return;
    final active = state as POSActive;

    if (query.isEmpty) {
      emit(
        active.copyWith(searchResults: [], searchStatus: SearchStatus.initial),
      );
      return;
    }

    emit(active.copyWith(searchStatus: SearchStatus.searching));

    try {
      final products = await _database.getProducts();
      final results = products.where((p) {
        final q = query.toLowerCase();
        final matchesQuery =
            p.name.toLowerCase().contains(q) ||
            (p.barcode?.contains(q) ?? false) ||
            (p.scientificName?.toLowerCase().contains(q) ?? false);

        final matchesCategory =
            active.selectedCategoryId == null ||
            p.categoryId == active.selectedCategoryId;

        return matchesQuery && matchesCategory;
      }).toList();

      if (results.isEmpty) {
        emit(
          active.copyWith(
            searchResults: [],
            searchStatus: SearchStatus.noResults,
          ),
        );
      } else {
        emit(
          active.copyWith(
            searchResults: results,
            searchStatus: SearchStatus.found,
          ),
        );
      }
    } catch (e) {
      emit(POSError('خطأ في البحث: $e'));
    }
  }

  Future<void> handleBarcodeScan(String barcode) async {
    if (state is! POSActive || barcode.isEmpty) return;

    try {
      final products = await _database.getProducts();
      final product = products.firstWhere(
        (p) => p.barcode?.trim() == barcode.trim(),
        orElse: () => throw Exception('Product not found'),
      );

      addToCart(product);
    } catch (e) {
      // Just emit results found if it doesn't match exactly,
      // or maybe it's partially scanned/typed
      searchProducts(barcode);
    }
  }

  void setCategory(int? categoryId) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    emit(
      active.copyWith(
        selectedCategoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
    // Re-trigger search if there's text
    // (In a real app, we might want to store the last query)
  }

  void addToCart(Product product) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    final cart = List<CartItem>.from(active.cart);

    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cart[index].quantity += 1;
    } else {
      cart.add(CartItem(product: product, price: product.price));
    }

    emit(
      active.copyWith(
        cart: cart,
        searchResults: [],
        searchStatus: SearchStatus.initial,
      ),
    );
  }

  void updateQuantity(int productId, int quantity) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    final cart = List<CartItem>.from(active.cart);

    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index].quantity = quantity;
      }
      emit(active.copyWith(cart: cart));
    }
  }

  void removeFromCart(int productId) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    final cart = List<CartItem>.from(active.cart);
    cart.removeWhere((item) => item.product.id == productId);
    emit(active.copyWith(cart: cart));
  }

  void updateDiscount(double discount) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    emit(active.copyWith(discount: discount));
  }

  void setPaymentMethod(String method) {
    if (state is! POSActive) return;
    final active = state as POSActive;
    emit(active.copyWith(paymentMethod: method));
  }

  Future<void> finalizeSale() async {
    if (state is! POSActive) return;
    final active = state as POSActive;
    if (active.cart.isEmpty) {
      emit(POSError('السلة فارغة'));
      return;
    }

    emit(active.copyWith(isProcessing: true));
    try {
      final sale = Sale(
        shiftId: active.shift.id!,
        date: DateTime.now(),
        totalAmount: active.total,
        discount: active.discount,
        paymentMethod: active.paymentMethod,
      );

      final items = active.cart
          .map(
            (i) => SaleItem(
              saleId: 0, // Assigned correctly in txn
              productId: i.product.id!,
              quantity: i.quantity,
              price: i.price,
              subtotal: i.subtotal,
            ),
          )
          .toList();

      await _database.createSale(sale, items);
      emit(POSActionSuccess('تمت عملية البيع بنجاح'));
      emit(active.copyWith(cart: [], discount: 0.0, isProcessing: false));
    } catch (e) {
      emit(active.copyWith(isProcessing: false));
      emit(POSError('فشل في إتمام العملية: $e'));
    }
  }
}
