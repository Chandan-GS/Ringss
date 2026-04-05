import 'package:get/get.dart';
import 'package:project_a_b/bindings/auth_binding.dart';
import 'package:project_a_b/bindings/initial_binding.dart';
import 'package:project_a_b/bindings/shell_binding.dart';
import 'package:project_a_b/bindings/more_binding.dart'; // <-- IMPORT THIS
import 'package:project_a_b/core/routes/app_routes.dart';
import 'package:project_a_b/screens/auth/login_screen.dart';
import 'package:project_a_b/screens/auth/signup_screen.dart';
import 'package:project_a_b/screens/auth/start_screen.dart';
import 'package:project_a_b/screens/community/community_list_screen.dart';
import 'package:project_a_b/screens/profile/more_screen.dart';
import 'package:project_a_b/screens/profile/source_screen.dart';
import 'package:project_a_b/screens/rings/rings_management_screen.dart';
import 'package:project_a_b/screens/shell/shell_screen.dart';
import 'package:project_a_b/screens/signals/signals_feed_screen.dart';

class AppPages {
  static const INITIAL = AppRoutes.SHELL;

  static final routes = [
    GetPage(
      name: AppRoutes.START,
      page: () => const StartScreen(),
      binding: InitialBinding(),
    ),

    // -----------------------
    GetPage(
      name: AppRoutes.MORE,
      page: () => const MoreScreen(),
      binding: MoreBinding(), // <-- ADD THIS BINDING
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SHELL,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
    ),
    GetPage(name: '/signals', page: () => const SignalsFeedScreen()),
    GetPage(name: '/rings', page: () => const RingsManagementScreen()),
    GetPage(name: '/community', page: () => const CommunityListScreen()),
    GetPage(name: '/source', page: () => const SourceScreen()),
  ];
}
