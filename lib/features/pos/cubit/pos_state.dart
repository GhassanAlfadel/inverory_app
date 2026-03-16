import '../../../core/database/models.dart';

class CartItem {
  final Product product;
  int quantity;
  double price; // Can be overridden

  CartItem({required this.product, this.quantity = 1, required this.price});

  double get subtotal => price * quantity;
}

abstract class POSState {}

class POSInitial extends POSState {}

class POSLoading extends POSState {}

enum SearchStatus { initial, searching, noResults, found }

class POSActive extends POSState {
  final Shift shift;
  final List<CartItem> cart;
  final List<Product> searchResults;
  final SearchStatus searchStatus;
  final double discount;
  final String paymentMethod;
  final bool isProcessing;
  final List<Category> categories;
  final int? selectedCategoryId;

  POSActive({
    required this.shift,
    this.cart = const [],
    this.searchResults = const [],
    this.searchStatus = SearchStatus.initial,
    this.discount = 0.0,
    this.paymentMethod = 'cash',
    this.isProcessing = false,
    this.categories = const [],
    this.selectedCategoryId,
  });

  double get subtotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount;

  POSActive copyWith({
    Shift? shift,
    List<CartItem>? cart,
    List<Product>? searchResults,
    SearchStatus? searchStatus,
    double? discount,
    String? paymentMethod,
    bool? isProcessing,
    List<Category>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return POSActive(
      shift: shift ?? this.shift,
      cart: cart ?? this.cart,
      searchResults: searchResults ?? this.searchResults,
      searchStatus: searchStatus ?? this.searchStatus,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}

class POSNoActiveShift extends POSState {}

class POSError extends POSState {
  final String message;
  POSError(this.message);
}

class POSActionSuccess extends POSState {
  final String message;
  POSActionSuccess(this.message);
}
