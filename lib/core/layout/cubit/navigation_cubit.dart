import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum NavigationScreen {
  dashboard,
  medicines,
  categories,
  suppliers,
  purchases,
  pos,
  shifts,
  expenses,
  sales,
  addProduct,
  editProduct,
  addPurchase,
  viewPurchase,
  reports,
  users,
  settings,
  addLaptop,
  editLaptop,
  addPhone,
  editPhone,
  addAccessory,
  editAccessory,
  invoices,
  invoiceDetails,
}

class NavigationState extends Equatable {
  final NavigationScreen screen;
  final dynamic data;

  const NavigationState(this.screen, {this.data});

  @override
  List<Object?> get props => [screen, data];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(NavigationScreen.dashboard));

  void setScreen(NavigationScreen screen, {dynamic data}) {
    emit(NavigationState(screen, data: data));
  }
}
