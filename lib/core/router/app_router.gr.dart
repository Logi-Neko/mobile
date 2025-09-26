// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AuthSelectionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AuthSelectionScreen(),
      );
    },
    CharacterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CharacterScreen(),
      );
    },
    CountdownRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CountdownScreen(),
      );
    },
    CourseRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CourseScreen(),
      );
    },
    CustomerAuthRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CustomerAuthScreen(),
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ForgotPasswordScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    QuizResultRoute.name: (routeData) {
      final args = routeData.argsAs<QuizResultRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: QuizResultScreen(
          key: args.key,
          questions: args.questions,
          answers: args.answers,
          score: args.score,
        ),
      );
    },
    RoomQuizRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RoomQuizScreen(),
      );
    },
    SignUpStepOneRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpStepOneScreen(),
      );
    },
    SignUpStepTwoRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<SignUpStepTwoRouteArgs>(
          orElse: () => SignUpStepTwoRouteArgs(
                username: pathParams.getString('username'),
                email: pathParams.getString('email'),
              ));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignUpStepTwoScreen(
          key: args.key,
          username: args.username,
          email: args.email,
        ),
      );
    },
    StartRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const StartScreen(),
      );
    },
    SubscriptionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SubscriptionScreen(),
      );
    },
    WaitingRoomRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WaitingRoomScreen(),
      );
    },
  };
}

/// generated route for
/// [AuthSelectionScreen]
class AuthSelectionRoute extends PageRouteInfo<void> {
  const AuthSelectionRoute({List<PageRouteInfo>? children})
      : super(
          AuthSelectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthSelectionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CharacterScreen]
class CharacterRoute extends PageRouteInfo<void> {
  const CharacterRoute({List<PageRouteInfo>? children})
      : super(
          CharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'CharacterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CountdownScreen]
class CountdownRoute extends PageRouteInfo<void> {
  const CountdownRoute({List<PageRouteInfo>? children})
      : super(
          CountdownRoute.name,
          initialChildren: children,
        );

  static const String name = 'CountdownRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CourseScreen]
class CourseRoute extends PageRouteInfo<void> {
  const CourseRoute({List<PageRouteInfo>? children})
      : super(
          CourseRoute.name,
          initialChildren: children,
        );

  static const String name = 'CourseRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CustomerAuthScreen]
class CustomerAuthRoute extends PageRouteInfo<void> {
  const CustomerAuthRoute({List<PageRouteInfo>? children})
      : super(
          CustomerAuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomerAuthRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ForgotPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForgotPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [QuizResultScreen]
class QuizResultRoute extends PageRouteInfo<QuizResultRouteArgs> {
  QuizResultRoute({
    Key? key,
    required List<Question> questions,
    required Map<int, String> answers,
    required int score,
    List<PageRouteInfo>? children,
  }) : super(
          QuizResultRoute.name,
          args: QuizResultRouteArgs(
            key: key,
            questions: questions,
            answers: answers,
            score: score,
          ),
          initialChildren: children,
        );

  static const String name = 'QuizResultRoute';

  static const PageInfo<QuizResultRouteArgs> page =
      PageInfo<QuizResultRouteArgs>(name);
}

class QuizResultRouteArgs {
  const QuizResultRouteArgs({
    this.key,
    required this.questions,
    required this.answers,
    required this.score,
  });

  final Key? key;

  final List<Question> questions;

  final Map<int, String> answers;

  final int score;

  @override
  String toString() {
    return 'QuizResultRouteArgs{key: $key, questions: $questions, answers: $answers, score: $score}';
  }
}

/// generated route for
/// [RoomQuizScreen]
class RoomQuizRoute extends PageRouteInfo<void> {
  const RoomQuizRoute({List<PageRouteInfo>? children})
      : super(
          RoomQuizRoute.name,
          initialChildren: children,
        );

  static const String name = 'RoomQuizRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignUpStepOneScreen]
class SignUpStepOneRoute extends PageRouteInfo<void> {
  const SignUpStepOneRoute({List<PageRouteInfo>? children})
      : super(
          SignUpStepOneRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpStepOneRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignUpStepTwoScreen]
class SignUpStepTwoRoute extends PageRouteInfo<SignUpStepTwoRouteArgs> {
  SignUpStepTwoRoute({
    Key? key,
    required String username,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
          SignUpStepTwoRoute.name,
          args: SignUpStepTwoRouteArgs(
            key: key,
            username: username,
            email: email,
          ),
          rawPathParams: {
            'username': username,
            'email': email,
          },
          initialChildren: children,
        );

  static const String name = 'SignUpStepTwoRoute';

  static const PageInfo<SignUpStepTwoRouteArgs> page =
      PageInfo<SignUpStepTwoRouteArgs>(name);
}

class SignUpStepTwoRouteArgs {
  const SignUpStepTwoRouteArgs({
    this.key,
    required this.username,
    required this.email,
  });

  final Key? key;

  final String username;

  final String email;

  @override
  String toString() {
    return 'SignUpStepTwoRouteArgs{key: $key, username: $username, email: $email}';
  }
}

/// generated route for
/// [StartScreen]
class StartRoute extends PageRouteInfo<void> {
  const StartRoute({List<PageRouteInfo>? children})
      : super(
          StartRoute.name,
          initialChildren: children,
        );

  static const String name = 'StartRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SubscriptionScreen]
class SubscriptionRoute extends PageRouteInfo<void> {
  const SubscriptionRoute({List<PageRouteInfo>? children})
      : super(
          SubscriptionRoute.name,
          initialChildren: children,
        );

  static const String name = 'SubscriptionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WaitingRoomScreen]
class WaitingRoomRoute extends PageRouteInfo<void> {
  const WaitingRoomRoute({List<PageRouteInfo>? children})
      : super(
          WaitingRoomRoute.name,
          initialChildren: children,
        );

  static const String name = 'WaitingRoomRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
