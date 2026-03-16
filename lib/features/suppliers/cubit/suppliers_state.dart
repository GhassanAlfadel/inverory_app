import 'package:equatable/equatable.dart';
import '../../../core/database/models.dart';

abstract class SuppliersState extends Equatable {
  const SuppliersState();

  @override
  List<Object?> get props => [];
}

class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {}

class SuppliersLoaded extends SuppliersState {
  final List<Supplier> suppliers;
  final String? searchQuery;

  const SuppliersLoaded({required this.suppliers, this.searchQuery});

  @override
  List<Object?> get props => [suppliers, searchQuery];
}

class SuppliersError extends SuppliersState {
  final String message;
  const SuppliersError(this.message);

  @override
  List<Object?> get props => [message];
}

class SupplierActionSuccess extends SuppliersState {
  final String message;
  const SupplierActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
