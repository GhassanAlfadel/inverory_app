import 'package:equatable/equatable.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final Map<String, double> totals;
  final List<Map<String, dynamic>> productSales;

  const ReportsLoaded({required this.totals, required this.productSales});

  @override
  List<Object?> get props => [totals, productSales];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
