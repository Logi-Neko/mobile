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
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
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
