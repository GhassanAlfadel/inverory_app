import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  const AuthState(this.status);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository)
    : super(const AuthState(AuthStatus.unauthenticated));

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      emit(const AuthState(AuthStatus.authenticated));
    } else {
      emit(const AuthState(AuthStatus.unauthenticated));
    }
  }

  Future<void> login() async {
    await _authRepository.setLoggedIn(true);
    emit(const AuthState(AuthStatus.authenticated));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(AuthStatus.unauthenticated));
  }
}
