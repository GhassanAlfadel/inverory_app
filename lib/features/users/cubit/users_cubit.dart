import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final AppDatabase _database;

  UsersCubit(this._database) : super(UsersInitial());

  Future<void> loadUsers() async {
    emit(UsersLoading());
    try {
      final users = await _database.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> addUser(User user) async {
    try {
      await _database.addUser(user);
      emit(UserActionSuccess('تم إضافة المستخدم بنجاح'));
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _database.updateUser(user);
      emit(UserActionSuccess('تم تحديث بيانات المستخدم بنجاح'));
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _database.deleteUser(id);
      emit(UserActionSuccess('تم حذف المستخدم بنجاح'));
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}
