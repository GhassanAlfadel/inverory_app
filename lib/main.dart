import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/app_database.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/cubit/auth_cubit.dart';
import 'core/layout/ui/main_layout.dart';
import 'core/layout/cubit/layout_cubit.dart';
import 'core/layout/cubit/navigation_cubit.dart';
import 'features/products/cubit/products_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/auth/ui/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final authRepository = AuthRepository();
  runApp(InventoryApp(database: database, authRepository: authRepository));
}

class InventoryApp extends StatelessWidget {
  final AppDatabase database;
  final AuthRepository authRepository;

  const InventoryApp({
    super.key,
    required this.database,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: database),
        RepositoryProvider.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
          ),
          BlocProvider(create: (context) => LayoutCubit()),
          BlocProvider(create: (context) => NavigationCubit()),
          BlocProvider(
            create: (context) =>
                ProductsCubit(RepositoryProvider.of<AppDatabase>(context))
                  ..loadProducts(),
          ),
          BlocProvider(
            create: (context) =>
                SettingsCubit(RepositoryProvider.of<AppDatabase>(context))
                  ..loadSettings(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(
            1440,
            900,
          ), // Standard desktop/tablet design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'صيدلية الشفاء',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
                textTheme: GoogleFonts.cairoTextTheme(),
                scaffoldBackgroundColor: const Color(0xFFF3F4F6),
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar', 'AE')],
              locale: const Locale('ar', 'AE'),
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    return const MainLayout();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
