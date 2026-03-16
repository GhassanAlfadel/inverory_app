import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inverory_app/core/database/app_database.dart';
import '../../../core/auth/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AppDatabase database;
  final AuthRepository authRepository;

  LoginCubit(this.database, this.authRepository) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    emit(LoginLoading());
    try {
      // Simulate network delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await database.login(username, password);

      if (user != null) {
        await authRepository.setLoggedIn(true);
        emit(LoginSuccess());
      } else {
        emit(
          const LoginFailure(error: 'اسم المستخدم أو كلمة المرور غير صحيحة'),
        );
      }
    } catch (e) {
      emit(LoginFailure(error: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
