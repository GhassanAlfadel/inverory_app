import 'package:equatable/equatable.dart';
import '../../../core/database/models.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Category> categories;

  const ProductsLoaded({this.products = const [], this.categories = const []});

  @override
  List<Object> get props => [products, categories];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  @override
  List<Object> get props => [message];
}
