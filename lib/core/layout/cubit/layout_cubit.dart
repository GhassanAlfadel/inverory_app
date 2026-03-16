import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// State
class LayoutState extends Equatable {
  final bool isSidebarExpanded;
  const LayoutState({this.isSidebarExpanded = true});

  @override
  List<Object> get props => [isSidebarExpanded];

  LayoutState copyWith({bool? isSidebarExpanded}) {
    return LayoutState(
      isSidebarExpanded: isSidebarExpanded ?? this.isSidebarExpanded,
    );
  }
}

// Cubit
class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(const LayoutState());

  void toggleSidebar() {
    emit(state.copyWith(isSidebarExpanded: !state.isSidebarExpanded));
  }
}
