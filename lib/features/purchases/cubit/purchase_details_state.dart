import 'package:equatable/equatable.dart';

abstract class PurchaseDetailsState extends Equatable {
  const PurchaseDetailsState();

  @override
  List<Object?> get props => [];
}

class PurchaseDetailsInitial extends PurchaseDetailsState {}

class PurchaseDetailsLoading extends PurchaseDetailsState {}

class PurchaseDetailsLoaded extends PurchaseDetailsState {
  final Map<String, dynamic> purchase;
  final List<Map<String, dynamic>> items;

  const PurchaseDetailsLoaded({required this.purchase, required this.items});

  @override
  List<Object?> get props => [purchase, items];
}

class PurchaseDetailsError extends PurchaseDetailsState {
  final String message;
  const PurchaseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
