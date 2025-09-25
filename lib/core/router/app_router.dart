import 'package:flutter/cupertino.dart';
import 'package:logi_neko/features/auth/screens/auth_selection.dart';
import 'package:logi_neko/features/home/ui/screen/home_screen.dart';
import 'package:logi_neko/features/login/screen/login_screen.dart';
import 'package:logi_neko/features/login/screen/start_screen.dart';
import 'package:logi_neko/features/login/screen/customer_auth_screen.dart';

import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/features/subcription/screen/subcription.dart';

import '../../features/course/ui/screen/course_main_screen.dart';
import '../../features/login/screen/forgot_password_screen.dart';
import '../../features/auth/screens/signup_step_one_screen.dart';
import '../../features/auth/screens/signup_step_two_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartRoute.page, initial: true),
    AutoRoute(page: CustomerAuthRoute.page, path: '/customer-auth'),
    AutoRoute(page: AuthSelectionRoute.page, path: '/auth-selection'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
    AutoRoute(page: SignUpStepOneRoute.page,path: '/register/step-one'),
    AutoRoute(page: SignUpStepTwoRoute.page, path: '/register/step-two/:username/:email'),
    AutoRoute(page: CourseRoute.page, path: '/course'),
    AutoRoute(page: HomeRoute.page, path: '/'),
    AutoRoute(page: SubscriptionRoute.page, path: '/subscription'),

    // Sau này thêm các màn khác ở đây
  ];
}

