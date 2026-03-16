import 'package:equatable/equatable.dart';
import '../../../core/database/models.dart';

abstract class PurchasesState extends Equatable {
  const PurchasesState();

  @override
  List<Object?> get props => [];
}

class PurchasesInitial extends PurchasesState {}

class PurchasesLoading extends PurchasesState {}

class PurchasesLoaded extends PurchasesState {
  final List<Supplier> suppliers;
  final List<Product> products;
  final List<Map<String, dynamic>> purchaseHistory;
  final List<PurchaseItem> tempItems;

  const PurchasesLoaded({
    required this.suppliers,
    required this.products,
    this.purchaseHistory = const [],
    this.tempItems = const [],
  });

  @override
  List<Object?> get props => [suppliers, products, purchaseHistory, tempItems];

  PurchasesLoaded copyWith({
    List<Supplier>? suppliers,
    List<Product>? products,
    List<Map<String, dynamic>>? purchaseHistory,
    List<PurchaseItem>? tempItems,
  }) {
    return PurchasesLoaded(
      suppliers: suppliers ?? this.suppliers,
      products: products ?? this.products,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      tempItems: tempItems ?? this.tempItems,
    );
  }
}

class PurchasesError extends PurchasesState {
  final String message;
  const PurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}

class PurchaseSavedSuccess extends PurchasesState {}
