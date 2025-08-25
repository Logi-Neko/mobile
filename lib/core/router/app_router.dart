import 'package:logi_neko/features/login/screen/start_screen.dart';
import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StartRoute.page, initial: true),
    // Sau này thêm các màn khác ở đây
  ];
}
