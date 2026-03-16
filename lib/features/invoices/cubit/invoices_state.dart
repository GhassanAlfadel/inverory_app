import 'package:equatable/equatable.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<Map<String, dynamic>> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoiceDetailsLoaded extends InvoicesState {
  final Map<String, dynamic> invoice;
  final List<Map<String, dynamic>> items;

  const InvoiceDetailsLoaded(this.invoice, this.items);

  @override
  List<Object?> get props => [invoice, items];
}

class InvoicesError extends InvoicesState {
  final String message;

  const InvoicesError(this.message);

  @override
  List<Object?> get props => [message];
}
