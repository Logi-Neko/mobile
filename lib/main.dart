import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/core/navigation/navigation_service.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/core/services/google_sign_in_service.dart';
import 'package:logi_neko/features/auth/repository/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logi_neko/features/home/bloc/home_bloc.dart';
import 'package:logi_neko/features/home/repository/home_repo.dart';
import 'features/auth/bloc/auth_bloc.dart';

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Force landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize services
  ApiService.initialize();
  GoogleSignInService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(HomeRepositoryImpl())
            ..add(GetUserInfo()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'LogiNeko',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.config(),
        builder: (context, child) {
          // Setup NavigationService với context từ MaterialApp
          NavigationService.instance.setContext(context);
          return child ?? Container();
        },
      ),
    );
  }
}