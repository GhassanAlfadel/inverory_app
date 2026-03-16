import '../../../core/database/models.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}

class UserActionSuccess extends UsersState {
  final String message;
  UserActionSuccess(this.message);
}
