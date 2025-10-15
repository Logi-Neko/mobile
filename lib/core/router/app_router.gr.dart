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
      final args = routeData.argsAs<CharacterRouteArgs>(
          orElse: () => const CharacterRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CharacterScreen(
          key: args.key,
          user: args.user,
        ),
      );
    },
    ContestListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContestListScreen(),
      );
    },
    ContestResultRoute.name: (routeData) {
      final args = routeData.argsAs<ContestResultRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ContestResultScreen(
          key: args.key,
          contestId: args.contestId,
          totalScore: args.totalScore,
          totalQuestions: args.totalQuestions,
          correctAnswers: args.correctAnswers,
        ),
      );
    },
    CountdownRoute.name: (routeData) {
      final args = routeData.argsAs<CountdownRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CountdownScreen(
          key: args.key,
          contestId: args.contestId,
          participantId: args.participantId,
        ),
      );
    },
    CourseRoute.name: (routeData) {
      final args = routeData.argsAs<CourseRouteArgs>(
          orElse: () => const CourseRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CourseScreen(
          key: args.key,
          userIsPremium: args.userIsPremium,
        ),
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
    LeaderboardRoute.name: (routeData) {
      final args = routeData.argsAs<LeaderboardRouteArgs>(
          orElse: () => const LeaderboardRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LeaderboardScreen(
          key: args.key,
          currentUser: args.currentUser,
        ),
      );
    },
    LearningReportRoute.name: (routeData) {
      final args = routeData.argsAs<LearningReportRouteArgs>(
          orElse: () => const LearningReportRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LearningReportPage(
          key: args.key,
          accountId: args.accountId,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MyCharacterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyCharacterScreen(),
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
          contestId: args.contestId,
          totalTime: args.totalTime,
        ),
      );
    },
    RoomQuizRoute.name: (routeData) {
      final args = routeData.argsAs<RoomQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RoomQuizScreen(
          key: args.key,
          contestId: args.contestId,
          participantId: args.participantId,
        ),
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
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
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
      final args = routeData.argsAs<WaitingRoomRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WaitingRoomScreen(
          key: args.key,
          contestId: args.contestId,
        ),
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
class CharacterRoute extends PageRouteInfo<CharacterRouteArgs> {
  CharacterRoute({
    Key? key,
    User? user,
    List<PageRouteInfo>? children,
  }) : super(
          CharacterRoute.name,
          args: CharacterRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'CharacterRoute';

  static const PageInfo<CharacterRouteArgs> page =
      PageInfo<CharacterRouteArgs>(name);
}

class CharacterRouteArgs {
  const CharacterRouteArgs({
    this.key,
    this.user,
  });

  final Key? key;

  final User? user;

  @override
  String toString() {
    return 'CharacterRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [ContestListScreen]
class ContestListRoute extends PageRouteInfo<void> {
  const ContestListRoute({List<PageRouteInfo>? children})
      : super(
          ContestListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContestListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContestResultScreen]
class ContestResultRoute extends PageRouteInfo<ContestResultRouteArgs> {
  ContestResultRoute({
    Key? key,
    required int contestId,
    required int totalScore,
    required int totalQuestions,
    required int correctAnswers,
    List<PageRouteInfo>? children,
  }) : super(
          ContestResultRoute.name,
          args: ContestResultRouteArgs(
            key: key,
            contestId: contestId,
            totalScore: totalScore,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
          ),
          initialChildren: children,
        );

  static const String name = 'ContestResultRoute';

  static const PageInfo<ContestResultRouteArgs> page =
      PageInfo<ContestResultRouteArgs>(name);
}

class ContestResultRouteArgs {
  const ContestResultRouteArgs({
    this.key,
    required this.contestId,
    required this.totalScore,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  final Key? key;

  final int contestId;

  final int totalScore;

  final int totalQuestions;

  final int correctAnswers;

  @override
  String toString() {
    return 'ContestResultRouteArgs{key: $key, contestId: $contestId, totalScore: $totalScore, totalQuestions: $totalQuestions, correctAnswers: $correctAnswers}';
  }
}

/// generated route for
/// [CountdownScreen]
class CountdownRoute extends PageRouteInfo<CountdownRouteArgs> {
  CountdownRoute({
    Key? key,
    required int contestId,
    required int participantId,
    List<PageRouteInfo>? children,
  }) : super(
          CountdownRoute.name,
          args: CountdownRouteArgs(
            key: key,
            contestId: contestId,
            participantId: participantId,
          ),
          initialChildren: children,
        );

  static const String name = 'CountdownRoute';

  static const PageInfo<CountdownRouteArgs> page =
      PageInfo<CountdownRouteArgs>(name);
}

class CountdownRouteArgs {
  const CountdownRouteArgs({
    this.key,
    required this.contestId,
    required this.participantId,
  });

  final Key? key;

  final int contestId;

  final int participantId;

  @override
  String toString() {
    return 'CountdownRouteArgs{key: $key, contestId: $contestId, participantId: $participantId}';
  }
}

/// generated route for
/// [CourseScreen]
class CourseRoute extends PageRouteInfo<CourseRouteArgs> {
  CourseRoute({
    Key? key,
    bool userIsPremium = false,
    List<PageRouteInfo>? children,
  }) : super(
          CourseRoute.name,
          args: CourseRouteArgs(
            key: key,
            userIsPremium: userIsPremium,
          ),
          initialChildren: children,
        );

  static const String name = 'CourseRoute';

  static const PageInfo<CourseRouteArgs> page = PageInfo<CourseRouteArgs>(name);
}

class CourseRouteArgs {
  const CourseRouteArgs({
    this.key,
    this.userIsPremium = false,
  });

  final Key? key;

  final bool userIsPremium;

  @override
  String toString() {
    return 'CourseRouteArgs{key: $key, userIsPremium: $userIsPremium}';
  }
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
/// [LeaderboardScreen]
class LeaderboardRoute extends PageRouteInfo<LeaderboardRouteArgs> {
  LeaderboardRoute({
    Key? key,
    User? currentUser,
    List<PageRouteInfo>? children,
  }) : super(
          LeaderboardRoute.name,
          args: LeaderboardRouteArgs(
            key: key,
            currentUser: currentUser,
          ),
          initialChildren: children,
        );

  static const String name = 'LeaderboardRoute';

  static const PageInfo<LeaderboardRouteArgs> page =
      PageInfo<LeaderboardRouteArgs>(name);
}

class LeaderboardRouteArgs {
  const LeaderboardRouteArgs({
    this.key,
    this.currentUser,
  });

  final Key? key;

  final User? currentUser;

  @override
  String toString() {
    return 'LeaderboardRouteArgs{key: $key, currentUser: $currentUser}';
  }
}

/// generated route for
/// [LearningReportPage]
class LearningReportRoute extends PageRouteInfo<LearningReportRouteArgs> {
  LearningReportRoute({
    Key? key,
    int? accountId,
    List<PageRouteInfo>? children,
  }) : super(
          LearningReportRoute.name,
          args: LearningReportRouteArgs(
            key: key,
            accountId: accountId,
          ),
          initialChildren: children,
        );

  static const String name = 'LearningReportRoute';

  static const PageInfo<LearningReportRouteArgs> page =
      PageInfo<LearningReportRouteArgs>(name);
}

class LearningReportRouteArgs {
  const LearningReportRouteArgs({
    this.key,
    this.accountId,
  });

  final Key? key;

  final int? accountId;

  @override
  String toString() {
    return 'LearningReportRouteArgs{key: $key, accountId: $accountId}';
  }
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
/// [MyCharacterScreen]
class MyCharacterRoute extends PageRouteInfo<void> {
  const MyCharacterRoute({List<PageRouteInfo>? children})
      : super(
          MyCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyCharacterRoute';

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
    required int contestId,
    Duration totalTime = const Duration(minutes: 3, seconds: 42),
    List<PageRouteInfo>? children,
  }) : super(
          QuizResultRoute.name,
          args: QuizResultRouteArgs(
            key: key,
            questions: questions,
            answers: answers,
            score: score,
            contestId: contestId,
            totalTime: totalTime,
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
    required this.contestId,
    this.totalTime = const Duration(minutes: 3, seconds: 42),
  });

  final Key? key;

  final List<Question> questions;

  final Map<int, String> answers;

  final int score;

  final int contestId;

  final Duration totalTime;

  @override
  String toString() {
    return 'QuizResultRouteArgs{key: $key, questions: $questions, answers: $answers, score: $score, contestId: $contestId, totalTime: $totalTime}';
  }
}

/// generated route for
/// [RoomQuizScreen]
class RoomQuizRoute extends PageRouteInfo<RoomQuizRouteArgs> {
  RoomQuizRoute({
    Key? key,
    required int contestId,
    required int participantId,
    List<PageRouteInfo>? children,
  }) : super(
          RoomQuizRoute.name,
          args: RoomQuizRouteArgs(
            key: key,
            contestId: contestId,
            participantId: participantId,
          ),
          initialChildren: children,
        );

  static const String name = 'RoomQuizRoute';

  static const PageInfo<RoomQuizRouteArgs> page =
      PageInfo<RoomQuizRouteArgs>(name);
}

class RoomQuizRouteArgs {
  const RoomQuizRouteArgs({
    this.key,
    required this.contestId,
    required this.participantId,
  });

  final Key? key;

  final int contestId;

  final int participantId;

  @override
  String toString() {
    return 'RoomQuizRouteArgs{key: $key, contestId: $contestId, participantId: $participantId}';
  }
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
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
class WaitingRoomRoute extends PageRouteInfo<WaitingRoomRouteArgs> {
  WaitingRoomRoute({
    Key? key,
    required int contestId,
    List<PageRouteInfo>? children,
  }) : super(
          WaitingRoomRoute.name,
          args: WaitingRoomRouteArgs(
            key: key,
            contestId: contestId,
          ),
          initialChildren: children,
        );

  static const String name = 'WaitingRoomRoute';

  static const PageInfo<WaitingRoomRouteArgs> page =
      PageInfo<WaitingRoomRouteArgs>(name);
}

class WaitingRoomRouteArgs {
  const WaitingRoomRouteArgs({
    this.key,
    required this.contestId,
  });

  final Key? key;

  final int contestId;

  @override
  String toString() {
    return 'WaitingRoomRouteArgs{key: $key, contestId: $contestId}';
  }
}
