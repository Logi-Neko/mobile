import 'package:flutter/cupertino.dart';
import 'package:logi_neko/features/auth/screens/auth_selection.dart';
import 'package:logi_neko/features/home/ui/screen/home_screen.dart';
import 'package:logi_neko/features/login/screen/login_screen.dart';
import 'package:logi_neko/features/login/screen/start_screen.dart';
import 'package:logi_neko/features/login/screen/customer_auth_screen.dart';
import 'package:logi_neko/features/room/screen/waiting_room_screen.dart';
import 'package:logi_neko/features/room/screen/countdown_screen.dart';
import 'package:logi_neko/features/room/screen/room_quiz_screen.dart';
import 'package:logi_neko/features/room/screen/quiz_result_screen.dart';
import 'package:logi_neko/features/room/dto/question.dart';
import 'package:logi_neko/features/character/ui/screen/character_screen.dart';
import 'package:logi_neko/features/character/ui/screen/my_character_screen.dart';
import 'package:logi_neko/features/splash/screen/splash_screen.dart';
import 'package:logi_neko/features/board/ui/screen/leaderboard_screen.dart';

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
    AutoRoute(page: SplashRoute.page, initial: true), // Splash screen as initial route
    AutoRoute(page: StartRoute.page, path: '/start'),
    AutoRoute(page: WaitingRoomRoute.page, path: '/waiting-room'),
    AutoRoute(page: CustomerAuthRoute.page, path: '/customer-auth'),
    AutoRoute(page: AuthSelectionRoute.page, path: '/auth-selection'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
    AutoRoute(page: SignUpStepOneRoute.page, path: '/register/step-one'),
    AutoRoute(page: SignUpStepTwoRoute.page, path: '/register/step-two/:username/:email'),
    AutoRoute(page: CourseRoute.page, path: '/course'),
    // Sau này thêm các màn khác ở đây
    AutoRoute(page: HomeRoute.page, path: '/'),
    AutoRoute(page: SubscriptionRoute.page, path: '/subscription'),
    AutoRoute(page: CountdownRoute.page, path: '/countdown'),
    AutoRoute(page: RoomQuizRoute.page, path: '/room-quiz'),
    AutoRoute(page: QuizResultRoute.page, path: '/quiz-result'),
    AutoRoute(page: CharacterRoute.page, path: '/character'),
    AutoRoute(page: MyCharacterRoute.page, path: '/my-character'),
    AutoRoute(page: LeaderboardRoute.page, path: '/leaderboard'),
  ];
}
